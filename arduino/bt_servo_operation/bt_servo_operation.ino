/**
 * @file bt_servo_operation.ino
 * @author Franz Chuquirachi (@franzcrs)
 * @brief Implements a way to operate the servos with commands send via bluetooth
 *    Chart of commands and the joint they actuate
 *    	 COMMAND			JOINT
 * 			ra(0x7261)	RIGHT ARM
 * 			la(0x6C61)  LEFT ARM
 * 			hz(0x687A)  HEAD Z-AXIS
 * 			hx(0x6878)  HEAD X-AXIS
 * 		Every input string must end with a Carriage Return character: 0x0d
 * @version 0.4
 * @date 2022-01-14
 * 
 * @copyright Copyright (c) 2022
 * 
 */

#include <SoftwareSerial.h>
#include <AltSoftSerial.h>
#include <Dynamixel2Arduino.h>
#include <stdarg.h>

/**
 * The DYNAMIXEL Shield uses digital pins (0,1) to communicate with the servos.
 * These are the same pins as in Arduino Uno/Mega, used for the usb communication.
 * Therefore, the wellknown 'Serial' interface (pins (0,1)) cannot be used and
 * another serial interface needs to be created. For the purpose of just sending
 * information to our Serial Monitor with no strict Baud rate requirement, 
 * SoftwareSerial library is enough.
 * For other boards, pins (0,1) are not connected to the usb connector.
 * For detailed information refer to:
 * https://www.arduino.cc/reference/en/language/functions/communication/serial/
 * https://emanual.robotis.com/docs/en/parts/interface/dynamixel_shield/
 * */
SoftwareSerial DEBUG_SERIAL(6, 7); // Arduino Uno pins (6,7) are (RX,TX) Serial pins for communication with Computer

/**
 * Bluetooth Communication requieres read and write operations through serial port and
 * demands a reliable data transference interface.
 * Unlike SoftwareSerial, AltSoftSerial can handle read and write operations consecutively
 * or simultaneously with no loss of data, and does not suffer from data corruption due to
 * interference with other functions, libraries or the hardware Serial.
 * On the other hand, it just have one pair of defined pins per Board for performing the
 * serial emulation. Pins (8,9) are AltSoftSerial pins (RX,TX) in case of Arduino Uno
 * For detailed information refer to:
 * https://www.pjrc.com/teensy/td_libs_AltSoftSerial.html
 * https://www.arduino.cc/en/Reference/SoftwareSerial
 * https://www.pjrc.com/teensy/td_libs_NewSoftSerial.html
 */
AltSoftSerial BT_SERIAL; // Arduino Uno pins (8,9) are (RX,TX) Serial pins for communication with Bluetooth Module

const float DXL_PROTOCOL_VERSION = 1.0;			// Servos AX-12A use protocol 1.0
																						// Refer to Compatibility Table in: https://emanual.robotis.com/docs/en/dxl/protocol1/
const uint8_t DXL_DIR_PIN = 2;							// The DYNAMIXEL Shield uses pin 2 as data flow direction control. Refer to Layout
																						// in: https://emanual.robotis.com/docs/en/parts/interface/dynamixel_shield/#layout
Dynamixel2Arduino dxl(Serial, DXL_DIR_PIN); // Declaring an instance of Dynamixel2Arduino. The DYNAMIXEL Shield exclusively uses
																						// the Serial interface of pins 0 and 1. Check Layout in the previous link.
using namespace ControlTableItem;						// Required namespace to use servo's Controltable item names

const byte COMM_LEN = 2;							// Length of commands to be received (User-defined)
const byte BUFFER_LEN = COMM_LEN + 1; // Buffer length equals command length + 1 space
const bool LEN_STRICT = true;					// Length strictness says if verification of command length is going to be performed
char message[BUFFER_LEN];							// Char array for received data. Length of array must be a const variable
byte index = 0;												// Index position of message char array and counter of characters received
bool returnMsg = false;								// Flag that tells whether a message was successfully obtained and ready to use
unsigned long indexIncrementTime;			// Variable for registering the timestamp in which happens the last index increment

/**
 * @brief Function for formatted printing in Arduino, same as printf of C language. Prints to DEBUG_SERIAL.
 * 
 * @param input Formatted string and then the variable names followed by comma
 */
void DEBUG_SERIALprintln(const char *input...)
{
	va_list args;
	va_start(args, input);
	for (const char *i = input; *i != 0; ++i)
	{
		if (*i != '%')
		{
			DEBUG_SERIAL.print(*i);
			continue;
		}
		switch (*(++i))
		{
		case '%':
			DEBUG_SERIAL.print('%');
			break;
		case 's':
			DEBUG_SERIAL.print(va_arg(args, char *));
			break;
		case 'd':
			DEBUG_SERIAL.print(va_arg(args, int), DEC);
			break;
		case 'b':
			DEBUG_SERIAL.print(va_arg(args, int), BIN);
			break;
		case 'o':
			DEBUG_SERIAL.print(va_arg(args, int), OCT);
			break;
		case 'x':
			DEBUG_SERIAL.print(va_arg(args, int), HEX);
			break;
		case 'f':
			DEBUG_SERIAL.print(va_arg(args, double), 2);
			break;
		}
	}
	DEBUG_SERIAL.println();
	va_end(args);
}

/**
 * @brief Run a back and forth motion for the servo with entered id
 * 
 * @param servoid id number of servo to move in uint8_t data type. List of servo IDs and their driven joints: 
 * 						1 - RIGHT ARM, 
 * 						2 - LEFT ARM, 
 * 						3 - HEAD Z-AXIS, 
 * 						4 - HEAD X-AXIS
 */
void backforthMotion(byte servoid)
{
	// Turning off the torque before writing in the EEPROM Area is a good practice
  dxl.writeControlTableItem(TORQUE_ENABLE, servoid, 0);
  // Configurations for Joint mode, refer to: https://emanual.robotis.com/docs/en/dxl/ax/ax-12a/#cwccw-angle-limit6-8
  dxl.writeControlTableItem(CW_ANGLE_LIMIT, servoid, 0);
  dxl.writeControlTableItem(CCW_ANGLE_LIMIT, servoid, 1023);
  dxl.writeControlTableItem(TORQUE_ENABLE, servoid, 1);
	float position = dxl.getPresentPosition(servoid, UNIT_DEGREE);
	position = position + 40;
	dxl.setGoalPosition(servoid, position, UNIT_DEGREE);
	delay(100);
	position = position - 40;
	dxl.setGoalPosition(servoid, position, UNIT_DEGREE);
}

/**
 * @brief Collects the received data in the buffer of BT_SERIAL interface and store the characters inside 'message' array. 
 * 
 * @param strictlen Defines if the program will verify whether the received message has the expected command length.
 * If true, only if it has the exact length the command will be displayed. Otherwise, an error message will be displayed.
 * If false, the received message will be displayed anyways. The number of characters to display is limited by the command lenght.
 */
void BT_SERIALgetmessage(bool strictlen)
{
	if (index == 0) // index = 0 indicates the counter has been emptied, therefore program is ready to received a new message
	{
		DEBUG_SERIAL.println(F("--------------------------\r\n"
													 "Waiting for user input"));
		while (BT_SERIAL.available() == 0)
		{
		}
		DEBUG_SERIAL.println(F("Data received!"));
	}

	if (BT_SERIAL.available()) // Avoid to use while available since a software serial can return false in
														 // the middle of a transmitted string due to the nature of serial emulation
	{
		// if (index != 0) // After the first character is read, this code is executed
		// {
		// 	unsigned long dataAvailableAckTime = millis();
		// 	DEBUG_SERIALprintln("dataAvailableAckTime: %d", dataAvailableAckTime);
		// 	DEBUG_SERIALprintln("Elapsed time from last index increment to acknowledge of "
		// 											"new data available to read from BT module is: %d",
		// 											(dataAvailableAckTime - indexIncrementTime));
		// }
		char readchar = BT_SERIAL.read();
		if (readchar != '\r') // Read value is going to be manipulated only if is not the Carriage Return character: 0x0d
		{
			if (index < (BUFFER_LEN - 1)) // At least one space must be left empty at the end of our char array
																		// so that a null character can be added at the end, and therefore
																		// be printable through any of the print() methods
			{
				message[index] = readchar; // Read value is appended only if the index counter is a position before
																	 // the last position of message array (BUFFER_LEN - 1)
			}
			index++; // Anyways the index counter is incremented to track the number of characters received
			indexIncrementTime = millis();
			// DEBUG_SERIALprintln("indexIncrementTime: %d",indexIncrementTime);
		}
		else // Code to run when the read value IS the Carriage Return character: 0x0d
		{
			if (strictlen)
			{
				if (index != (BUFFER_LEN - 1))
				{
					DEBUG_SERIAL.println(F("ERROR: Input doesn't match command length"));
				}
				else
				{
					returnMsg = true;
				}
			}
			else
			{
				if (index > (BUFFER_LEN - 1))
				{
					DEBUG_SERIAL.println(F("WARNING: Input exceeds command length"));
				}
				returnMsg = true;
			}
			index = 0; // Only if there was a Carriage Return character, the counter is emptied
		}
	}
	else // When there is no data available in BT buffer
	{
		if (index != 0) // Handler of receiving data with no Carriage Return termination
										// When there is no data available and the index has not become 0 it can mean two things: a new
										// character is expected to be received and the verification happend just between the reception
										// of two chars of a message, or the already sent message did not have a Carriage return character
										// and no more data will come. On the second case we are facing an user error, but the program
										// needs to be able to handle it
		{
			// The way to identify that we are in the case of the user error is by checking the elapsed time from the last
			// index increment moment until the ocurrence of this situation. If the elapsed time is greater than 10ms it is
			// sure that we are not in the middle of bluetooth transmission (Tests were undergone for measuring the time)
			unsigned long currentTime = millis();
			unsigned long elapsedTime = currentTime - indexIncrementTime;
			if (elapsedTime > 100)
			{
				DEBUG_SERIAL.println(F("ERROR: Input didn't end with Cariage Return"));
				index = 0; // Now index is also emptied when message finished with no Carriage return character
			}
		}
	}
}

const PROGMEM char comm_1[] = "ra"; // TODO: Generate more motions
const PROGMEM char comm_2[] = "la";
const PROGMEM char comm_3[] = "hz";
const PROGMEM char comm_4[] = "hx";
const PROGMEM char desc_1[] = "right arm";
const PROGMEM char desc_2[] = "left arm";
const PROGMEM char desc_3[] = "head sideways";
const PROGMEM char desc_4[] = "head up and down";
/**
 * Commands Table (stored in Flash)
 */
const PROGMEM char *const commTable[] = {comm_1, comm_2, comm_3, comm_4};
/**
 * Descriptions Table (stored in Flash)
 */
const PROGMEM char *const descTable[] = {desc_1, desc_2, desc_3, desc_4};
char buffer[20];

/**
 * @brief Performs validation of received command against existing list of commands and translate it into a motion instruction
 * 
 */
void decodeCommand()
{
	if (returnMsg) // Decoding happens only when a message was received succesfully
	{
		returnMsg = false;				// Swaping to previous state
		BT_SERIAL.print(message); // Returning the read message to the sender
		delay(100);
		DEBUG_SERIALprintln("Received command: %s", message);
		int commCode; // Index of command inside the command table
		for (byte i = 0; i < sizeof(commTable) / sizeof(*commTable); i++)
		{
			commCode = -1; // Assigning an imposible value of "array index" in case no command is found
			strcpy_P(buffer,
							 (char *)pgm_read_word(&(commTable[i]))); // Operations that copy a string from program memory (Flash) to a
																												// string in RAM, as seen in: https://www.arduino.cc/reference/en/language/variables/utilities/progmem/
																												// Extraction of command in position i of the Commands Table
			if (strcmp(message, buffer) == 0)									// strcmp compares 2 strings. Refer to: https://www.cplusplus.com/reference/cstring/strcmp/
			{
				commCode = i;
				break;
			}
		}
		switch (commCode)
		{
		case -1:								// -1 means the no matching command was found in the Commands Table
			BT_SERIAL.print("n"); // Transmission of decoding result: "n" means "not identified"
			DEBUG_SERIAL.println(F("Command not identified"));
			break;
		default:																													 // Case in which a matching command was found
			BT_SERIAL.print("i");																						 // Transmission of enconding result: "i" means "identified"
			strcpy_P(buffer, (char *)pgm_read_word(&(descTable[commCode]))); // Extraction of description associated to command i
			DEBUG_SERIALprintln("Command identified\r\n"
													"Moving %s",
													buffer);
			backforthMotion(commCode + 1); // Send motion instruction to corresponding servo
			break;
		}
	}
}

const char *const onoffChart[] = {"OFF", "ON"};

void setup()
{
	DEBUG_SERIAL.begin(115200); // Initialize the Arduino - Computer communication interface
	// When working besides AltSoftSerial, SoftwareSerial rates must be greater than 10 times the AltSoftSerial rate.
	// Refer to 'Using Both SoftwareSerial and AltSoftSerial' section in: https://www.pjrc.com/teensy/td_libs_AltSoftSerial.html
	BT_SERIAL.begin(9600); // Initialize the Ardunio - Bluetooth Module communication interface
	// Default baud rate of HM-10 module is 9600 bps. Refer to: http://www.dsdtech-global.com/2017/08/hm-10.html
	dxl.begin(1000000); // Initialize Dynamixel communication interface, begin() method receives baudrate as input
	// Default baud rate of Servo AX-12A is 1 000 000 bps. Refer to: https://emanual.robotis.com/docs/en/dxl/ax/ax-12a/#baud-rate
	dxl.setPortProtocolVersion(DXL_PROTOCOL_VERSION); //Configuring the protocol version of instance

	DEBUG_SERIAL.println(F("THIS IS THE WIRELESS BLUETOOTH SERVO OPERATION PROGRAM\r\n"
												 "* Connect a device with Bluetooth 4.0 support to the 'DSD TECH' module\r\n"
												 "* End every command with a Carriage return character (0x0d, 13 or '\\r')"));
	DEBUG_SERIALprintln("* Command length: %d", COMM_LEN);
	DEBUG_SERIALprintln("* Length strictness is: %s", onoffChart[int(LEN_STRICT)]);
	DEBUG_SERIAL.println(F("* User can change these values by code-editing COMM_LEN and LEN_STRICT\r\n"
												 "--------------------------\r\n"
												 "Commands for servo operation:\r\n"
												 "- COMMAND -\t\t- JOINT -\r\n"
												 "ra(0x7261)\t RIGHT ARM\r\n"
												 "la(0x6C61)\t LEFT ARM\r\n"
												 "hz(0x687A)\t HEAD Z-AXIS\r\n"
												 "hx(0x6878)\t HEAD X-AXIS"));
}

void loop()
{
	BT_SERIALgetmessage(LEN_STRICT);
	decodeCommand();
}
