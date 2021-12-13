/**
 * @file bt_servo_operation.ino
 * @author Franz Chuquirachi (@franzcrs)
 * @brief Implements a way to operate the servos with commands send via bluetooth
 *    Chart of commands and the joint they actuate
 *    	 COMMAND   	   JOINT
 * 			ra(0x7261)	RIGHT ARM
 * 			la(0x6C61)  LEFT ARM
 * 			nz(0x6E7A)  NECK Z-AX ROT
 * 			nx(0x6E78)  NECK X-AX ROT
 * 		Every input string must end with a Carriage Return character: 0x0d
 * @version 0.1
 * @date 2021-12-08
 * 
 * @copyright Copyright (c) 2021
 * 
 */

/**
 * Chart of Servo IDs and its driven joint
 * 1 -- RIGHT ARM
 * 2 -- LEFT ARM
 * 3 -- NECK YAW
 * 4 -- NECK PITCH
 * 
 */

#include <SoftwareSerial.h>
#include <AltSoftSerial.h>
#include <DynamixelShield.h>
#include <stdarg.h>

/**
 * DYNAMIXELShield uses digital pins (0,1) to communicate with the servos.
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

const float DXL_PROTOCOL_VERSION = 1.0; // Servos AX-12A use protocol 1.0
// Refer to Compatibility Table in: https://emanual.robotis.com/docs/en/dxl/protocol1/
DynamixelShield dxl;									// Declaring an instance of DynamixelShield
using namespace ControlTableItem;			// Required namespace to use servo's Controltable item names

const byte COMM_LEN = 2;							// Length of commands to be received (User-defined)
const byte BUFFER_LEN = COMM_LEN + 1; // Buffer length equals command length + 1 space
const bool LEN_STRICT = false;				// Length strictness says if verification of command length is going to be performed (User-defined)
char message[BUFFER_LEN];							// Char array for received data. Length of array must be a const variable
byte index = 0;												// Index position of message char array

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
 * @brief Displays verification of existance of servo in the DEBUG_SERIAL interface and return the boolean result of the verification
 * 
 * @param id Id number of servo to verify in uint8_t data type
 */
bool verifyServo(byte id)
{
	if (dxl.ping(id) == true)
	{
		DEBUG_SERIALprintln("The servo with ID = %d exists, its model is: %d", id, dxl.getModelNumber(id));
		return true;
	}
	else
	{
		DEBUG_SERIALprintln("The servo with ID = %d doesn't exist", id);
		return false;
	}
}

/**
 * @brief Run a back and forth motion for the servo with entered id
 * 
 * @param id id number of servo to move in uint8_t data type
 */
void backforthMotion(byte id)
{
	float position = dxl.getPresentPosition(id, UNIT_DEGREE);
	position = position + 40;
	dxl.setGoalPosition(id, position, UNIT_DEGREE);
	delay(100);
	position = position - 40;
	dxl.setGoalPosition(id, position, UNIT_DEGREE);
}

/**
 * @brief Prints a loading pattern consisting on repeating a dot & Return for the times specified
 * 
 * @param repetitions number of repetitions of the loading pattern in uint8_t data type
 */
void loadingPattern(byte repetitions)
{
	delay(1700);
	for (byte i = 0; i < repetitions; i++)
	{
		DEBUG_SERIAL.println(" . ");
		delay(1700);
	}
}

/**
 * @brief Allows user to identify a servo among many by performing a motion on the current id count
 * 
 * @param id id number of servo to identify in uint8_t data type
 */
void indentifyServo(byte id)
{
	if (verifyServo(id))
	{
		loadingPattern(1);
		DEBUG_SERIALprintln("The mentioned servo is going to move");
		loadingPattern(1);
		dxl.torqueOff(id);
		dxl.setOperatingMode(id, OP_POSITION);
		dxl.torqueOn(id);
		backforthMotion(id);
		DEBUG_SERIALprintln("You can write down the joint the servo with ID = %d drives", id);
	}
	else
	{
		loadingPattern(1);
		DEBUG_SERIAL.println("You can ignore this count");
	}
}

/**
 * @brief Collects the transmitted data on BT_SERIAL interface from an external device and store the characters
 * inside message array of constant length. 
 * 
 * @param strictlen Defines if the program will verify whether the received message has the exact command length.
 * If true, only if it has the exact length the command will be displayed. Otherwise, an error message will be displayed.
 * If false, the received message will be displayed anyways. The number of characters to display is limited by the command lenght.
 */
void BT_SERIALgetmessage(bool strictlen)
{
	if (index == 0) // index = 0 indicates that program is ready to received a new message
	{
		DEBUG_SERIAL.println("--------------------------");
		DEBUG_SERIAL.println("Waiting for user input");
		while (BT_SERIAL.available() == 0)
		{
		}
		DEBUG_SERIAL.println("Data received!");
	}

	if (BT_SERIAL.available()) // Avoid to use while available since a software serial can return false in
														 // the middle of a transmitted string due to the nature of serial emulation
	{
		char readchar = BT_SERIAL.read();
		if (readchar != '\r') // Input message should end with a Carriage Return character: 0x0d
		{
			if (index < (BUFFER_LEN - 1)) // At least one space must be left empty at the end of our char array
																		// so that a null character can be added at the end, and therefore
																		// be printable through any of the print() methods
			{
				message[index] = readchar;
			}
			index++;
		}
		else
		{
			if (strictlen)
			{
				if (index != (BUFFER_LEN - 1))
				{
					DEBUG_SERIAL.println("ERROR: Input doesn't match command length");
				}
				else
				{
					BT_SERIAL.print(message);
					DEBUG_SERIALprintln("Received command: %s", message);
				}
			}
			else
			{
				if (index > (BUFFER_LEN - 1))
				{
					DEBUG_SERIAL.println("WARNING: Input exceeds command length");
				}
				BT_SERIAL.print(message);
				DEBUG_SERIALprintln("Received command: %s", message);
			}
			index = 0;
		}
	}
}

void setup()
{
	DEBUG_SERIAL.begin(115200); // Initialize the Arduino - Computer communication interface
	// When working besides AltSoftSerial, SoftwareSerial rates must be greater than 10 times the AltSoftSerial rate.
	// Refer to: https://www.pjrc.com/teensy/td_libs_AltSoftSerial.html
	BT_SERIAL.begin(9600); // Initialize the Ardunio - Bluetooth Module communication interface
	// HM-10 BT module default Baud rate is 9600 bps. Refer to: http://www.dsdtech-global.com/2017/08/hm-10.html
	dxl.begin(1000000); // Initialize Dynamixel communication interface, begin() method receives baudrate as input
	// Default baud rate of Servo AX-12A is 1 000 000 bps. Refer to: https://emanual.robotis.com/docs/en/dxl/ax/ax-12a/#baud-rate
	dxl.setPortProtocolVersion(DXL_PROTOCOL_VERSION); //Configuring the protocol version of instance

	DEBUG_SERIAL.println("THIS IS THE WIRELESS BLUETOOTH SERVO OPERATION PROGRAM");
	DEBUG_SERIAL.println("* Connect a device with Bluetooth 4.0 support to the 'DSD TECH' module");
	DEBUG_SERIAL.println("* End every command with a Carriage return character (0x0d, 13 or '\\r')");
	DEBUG_SERIALprintln("* Command length: %d", COMM_LEN);
	DEBUG_SERIAL.print("* Length strictness is: ");
	switch (LEN_STRICT)
	{
	case true:
		DEBUG_SERIAL.println("ON");
		break;

	default:
		DEBUG_SERIAL.println("OFF");
		break;
	}
	DEBUG_SERIAL.println("* User can change these values by code-editing COMM_LEN and LEN_STRICT");
}

void loop()
{
	BT_SERIALgetmessage(LEN_STRICT);
}
