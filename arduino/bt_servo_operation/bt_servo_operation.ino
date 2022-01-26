/**
 * @file bt_servo_operation.ino
 * @author Franz Chuquirachi (@franzcrs)
 * @brief Implements a way to operate the servos with commands send via bluetooth
 *    Command structure and table of values for parameter
 * 			- COMMAND STRING STRUCTURE -
 * 			| COMMAND NAME (2 chars)	| TARGET JOINT (2 chars)	| MOTION DIRECTION (1 char)	| MOTION INTENSITY (2 chars)	| CARRIAGE RETURN : 0x0d |
 * 			
 * 			- PARAMETERS CODIFICATION -
 *    	   COMMAND NAME			  CODE
 * 			Back Forth Motion		bf(0x6266)
 * 			Bounded Rotation		br(0x6272)
 * 			Infinite Rotation		ir(0x6972)
 * 			Home Position		  	hp(0x6870)
 * 			
 * 			TARGET JOINT	   CODE
 * 			Right Arm			ra(0x7261)
 * 			Left Arm			la(0x6C61)
 * 			Head Z-Axis		hz(0x687A)
 * 			Head X-Axis		hx(0x6878)
 * 
 * 			MOTION DIRECTION	 CODE
 * 			Clockwise			  	0(0x30)
 * 			Counterclockwise	1(0x31)
 * 
 * 			   MOTION INTENSITY						  CODE
 * 			No motion/Stop motion					00(0x3030)
 * 			Small/Slowest possible motion	01(0x3031)
 * 							...										02(0x3032)
 * 							...												...
 * 							...										09(0x3039)
 * 			Large/Fastest possible motion	10(0x3130)
 * @version 0.5
 * @date 2022-01-26
 * 
 * @copyright Copyright (c) 2022
 * 
 */

#include <SoftwareSerial.h>
#include <AltSoftSerial.h>
#include <Dynamixel2Arduino.h>
#include <stdarg.h>
#include <Dynamixel2ArduinoExtension.h>

/* Command Structure metrics (User defined) */
const byte COMM_LEN = 8;			 // Length of a complete Command String including terminating character
const byte COMM_NAME_LEN = 3;	 // Length of Command Name parameter as a single string
const byte TRG_JOINT_LEN = 3;	 // Length of Target Joint parameter as a single string
const byte MTN_DIREC_LEN = 2;	 // Length of Motion Direction parameter as a single string
const byte MTN_INTENS_LEN = 3; // Length of Motion Intensity parameter as a single string

/* Program Configuration */
const bool LEN_STRICT = true; // Length strictness says if verification of command length is going to be performed

/* Program Global Variables*/
char message[COMM_LEN]; // Buffer to store incomming data. Length of array must be a const variable
char commName[COMM_NAME_LEN],
		targetJoint[TRG_JOINT_LEN],
		motionDirec[MTN_DIREC_LEN],
		motionIntens[MTN_INTENS_LEN]; // Char array for every parameter of command string
byte index = 0;										// Index position of message char array and counter of characters received
bool returnMsg = false;						// Flag that tells whether a message was successfully obtained and ready to use
unsigned long indexIncrementTime; // Variable for registering the timestamp in which happens the last index increment

/* Servomotor Controller Class Configuration */
const float DXL_PROTOCOL_VERSION = 1.0;							 // Servos AX-12A use protocol 1.0
																										 // Refer to Compatibility Table in: https://emanual.robotis.com/docs/en/dxl/protocol1/
const uint8_t DXL_DIR_PIN = 2;											 // The DYNAMIXEL Shield uses pin 2 as data flow direction control. Refer to Layout
																										 // in: https://emanual.robotis.com/docs/en/parts/interface/dynamixel_shield/#layout
Dynamixel2ArduinoExtension dxl(Serial, DXL_DIR_PIN); // Declaring an instance of Dynamixel2Arduino. The DYNAMIXEL Shield exclusively uses
																										 // the Serial interface of pins 0 and 1. Check Layout in the previous link.
using namespace ControlTableItem;										 // Required namespace to use servo's Controltable item names

/* Debugging Serial Interface:
 * 
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

/* Bluetooth Serial Interface:
 *
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

/* Functions & Collections declaration */

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
 * @brief Run a back and forth motion in the servo with the entered id
 * 
 * @param servoID id of servo to move in uint8_t data type. List of servo IDs and their driven joints: 
 * 						1 - RIGHT ARM, 
 * 						2 - LEFT ARM, 
 * 						3 - HEAD Z-AXIS, 
 * 						4 - HEAD X-AXIS
 * @param direction starting direction of rotation in bool data type: 0 is CW, 1 is CCW.
 * @param extent displacement extent degree in uint8_t data type. From 0 to 10, being 10 the greatest displacement posible.
 */
void backforthMotion(byte servoID, bool direction, byte extent) //TODO: Implement sequential movement instead of delay
{
	// Turning off the torque before writing in the EEPROM Area is a good practice
	dxl.writeControlTableItem(TORQUE_ENABLE, servoID, 0);
	// Configurations for Joint mode, refer to: https://emanual.robotis.com/docs/en/dxl/ax/ax-12a/#cwccw-angle-limit6-8
	dxl.writeControlTableItem(CW_ANGLE_LIMIT, servoID, 0);
	dxl.writeControlTableItem(CCW_ANGLE_LIMIT, servoID, 1023);
	dxl.writeControlTableItem(MOVING_SPEED, servoID, 400); // Setting the speed in Moving speed field
	dxl.writeControlTableItem(TORQUE_ENABLE, servoID, 1);
	float position = dxl.getPresentPosition(servoID, UNIT_DEGREE);
	if ((position < 40 && !direction) || (position > 260 && direction))
	{
		direction = !direction;
	}
	float displacement = direction * (300 - position) * extent / 10 + !direction * (-1) * position * extent / 10;
	position = position + displacement;
	dxl.setGoalPosition(servoID, position, UNIT_DEGREE);
	delay(500);
	position = position - displacement;
	dxl.setGoalPosition(servoID, position, UNIT_DEGREE);
}
// TODO: Create new function that goes back and forth to one of the defined angles by dividing the available range in 10 portions and possibly turning the bollean in speed variable
// TODO: Create functions that goes direclty to one of the defined angles by dividing the available range in 10 portions
// TODO: Implement home position function and add to functions array and command table
// TODO: Define a identification validation response and motion conclusion response for bluetooth comunication
/**
 * @brief Iniciate an infinite rotation in the servo with the entered id. To stop change speed to 0.
 * 
 * @param servoID id of servo to move in uint8_t data type. List of servo IDs and their driven joints: 
 * 						1 - RIGHT ARM, 
 * 						2 - LEFT ARM
 * @param direction rotation direction in bool data type: 0 is CW, 1 is CCW.
 * @param quickness quickness of rotation in uint8_t data type. From 0 to 10, 10 gives the maximun speed posible.
 */
void infiniteRotation(byte servoID, bool direction, byte quickness)
{
	if (servoID == 3 || servoID == 4)
	{
		DEBUG_SERIAL.println(F("Error: Joints HEAD Z-AXIS and HEAD X-AXIS cannot perform an infinite rotation"));
		return;
	}
	unsigned int tableValue; // Variable buffer for storing Control Table values
	// Turning off the torque before writing in the EEPROM Area is a good practice
	dxl.writeControlTableItem(TORQUE_ENABLE, servoID, 0);
	// Configurations for Wheel mode, refer to: https://emanual.robotis.com/docs/en/dxl/ax/ax-12a/#cwccw-angle-limit6-8
	dxl.writeControlTableItem(CW_ANGLE_LIMIT, servoID, 0);
	dxl.writeControlTableItem(CCW_ANGLE_LIMIT, servoID, 0);
	dxl.writeControlTableItem(TORQUE_ENABLE, servoID, 1);
	tableValue = 1023 * quickness / 10 + !direction * 1024; // Calculating the Speed value. It also defines the direction.
	dxl.writeControlTableItem(MOVING_SPEED, servoID, tableValue);
}

/**
 * Joint's servomotor clockwise angle limits Table (in degrees, stored in Flash)
 * Allowed range of servo angles: 0 ~ 300 degrees
 * 
 */
const PROGMEM unsigned int CWlimitsTable[] = {0, 60, 60, 60};
/**
 * Joint's servomotor counter-clockwise angle limits Table (in degrees, stored in Flash)
 * Allowed range of servo angles: 0 ~ 300 degrees
 * 
 */
const PROGMEM unsigned int CCWlimitsTable[] = {240, 300, 240, 90};
/**
 * @brief Initiate a bounded rotation in the servo with the entered id
 * 
 * @param servoID id of servo to move in uint8_t data type. List of servo IDs and their driven joints: 
 * 						1 - RIGHT ARM, 
 * 						2 - LEFT ARM, 
 * 						3 - HEAD Z-AXIS, 
 * 						4 - HEAD X-AXIS
 * @param direction starting direction of rotation in bool data type: 0 is CW, 1 is CCW.
 * @param quickness quickness of rotation in uint8_t data type. From 0 to 10, 10 gives the maximun speed posible (114rpm).
 */
void boundedRotation(byte servoID, bool direction, byte quickness)
{
	if (quickness == 0)
	{
		return;
	}
	unsigned int tableValue; // Variable buffer for storing Control Table values
	unsigned int initialPos;
	unsigned int cwLimitTableValue, ccwLimitTableValue;

	// Turning off the torque before writing in the EEPROM Area is a good practice
	dxl.writeControlTableItem(TORQUE_ENABLE, servoID, 0);

	// Configurations for Joint mode. Refer to: https://emanual.robotis.com/docs/en/dxl/ax/ax-12a/#cwccw-angle-limit6-8
	tableValue = pgm_read_word_near(CWlimitsTable + servoID - 1); // Clockwise angle limit for the motor with the specified ID
	tableValue = (unsigned int)(3.41 * tableValue);								// Mapping angle limit in degrees to field-accepted values (0~1023).
	// Acording to documentation every unit in the field corresponds to 0.29 degrees. Refer to: https://emanual.robotis.com/docs/en/dxl/ax/ax-12a/#goal-position-30
	// Although there was a slight offset when dividing by 0.29 multiplying by the inverse, 3.41, makes the mapping from 0~300 degress to 0~1023 more accurate
	dxl.writeControlTableItem(CW_ANGLE_LIMIT, servoID, tableValue); // Setting lower limit for the specified motor
	cwLimitTableValue = tableValue;
	DEBUG_SERIALprintln("setting cwlimit as: %d", cwLimitTableValue);

	tableValue = pgm_read_word_near(CCWlimitsTable + servoID - 1);	 // Counter-clockwise angle limit for the motor with the specified ID
	tableValue = (unsigned int)(3.41 * tableValue);									 // Mapping angle limit in degrees to field-accepted values (0~1023).
	dxl.writeControlTableItem(CCW_ANGLE_LIMIT, servoID, tableValue); // Setting higher limit for the specified motor
	ccwLimitTableValue = tableValue;
	DEBUG_SERIALprintln("setting ccwlimit as: %d", ccwLimitTableValue);
	dxl.writeControlTableItem(TORQUE_ENABLE, servoID, 1);

	initialPos = dxl.getPresentPosition(servoID, UNIT_RAW);

	tableValue = 1023 * quickness / 10;																						// Moving Speed value to write in Control Table field
	dxl.writeControlTableItem(MOVING_SPEED, servoID, tableValue);									// Setting the speed in Moving speed field
	tableValue = direction * cwLimitTableValue + !direction * ccwLimitTableValue; // Opposite position than the first goal angle. Value to be written in Goal Position field
	dxl.regwriteControlTableItem(GOAL_POSITION, servoID, tableValue);							// Registering a Write instruction in memory for performing opposite rotation after first rotation
	tableValue = !direction * cwLimitTableValue + direction * ccwLimitTableValue; // First goal angle according to the direction value
	dxl.writeControlTableItem(GOAL_POSITION, servoID, tableValue);								// Performing the starting rotation towards the direction value

	while (dxl.readControlTableItem(MOVING, servoID)) // Reading moving status of servomotor. While true, program halts
	{
	}
	dxl.action(servoID); // Once the servo stops moving the action function will execute the registered Write instruction

	tableValue = initialPos;
	dxl.regwriteControlTableItem(GOAL_POSITION, servoID, tableValue); // Registering a Write instruction to return to initial position
	while (dxl.readControlTableItem(MOVING, servoID))									// Reading moving status of servomotor. While true, program halts
	{
	}
	dxl.action(servoID); // Once the servo stops moving the action function will execute the registered Write instruction
}

const char *const onoffChart[] = {"OFF", "ON"};

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
			if (index < (COMM_LEN - 1)) // Regardless of the number of characters received, lthe ast space of buffer must be
																	// left empty so that a null character can be added at the end, and therefore
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
				if (index != (COMM_LEN - 1))
				{
					DEBUG_SERIAL.print(F("Error: Input doesn't match command length. Program configuration Length strictness is "));
					DEBUG_SERIAL.println(onoffChart[LEN_STRICT]);
				}
				else
				{
					returnMsg = true;
				}
			}
			else
			{
				if (index > (COMM_LEN - 1))
				{
					DEBUG_SERIAL.print(F("Warning: Input exceeds command length. Program configuration Length strictness is "));
					DEBUG_SERIAL.println(onoffChart[LEN_STRICT]);
				}
				else if (index < (COMM_LEN - 1))
				{
					DEBUG_SERIAL.print(F("Warning: Input length is less than command length. Program configuration Length strictness is "));
					DEBUG_SERIAL.println(onoffChart[LEN_STRICT]);
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
				DEBUG_SERIAL.println(F("Error: Input did not end with Cariage Return"));
				index = 0; // Now index is also emptied when message finished with no Carriage return character
			}
		}
	}
}

/**
 * Pointer of type function with a defined structure
 * 
 */
typedef void (*FunctionCallback)(byte, bool, byte);

/**
 * Array of function pointers. Every function follow the structure defined in the function pointer declaration.
 * In the array: { backforthMotion, boundedRotation, infiniteRotation }
 * 
 */
FunctionCallback functions[] = {&backforthMotion,
																&boundedRotation,
																&infiniteRotation};

/**
 * Items for collections
 * 
 */
const PROGMEM char joint_1[] = "ra"; // Right arm
const PROGMEM char joint_2[] = "la"; // Left arm
const PROGMEM char joint_3[] = "hz"; // Head z-axis
const PROGMEM char joint_4[] = "hx"; // Head a-axis
const PROGMEM char jointdesc_1[] = "right arm";
const PROGMEM char jointdesc_2[] = "left arm";
const PROGMEM char jointdesc_3[] = "head's Z-axis";
const PROGMEM char jointdesc_4[] = "head's X-axis";
const PROGMEM char comm_1[] = "bf"; // Back and forth motion
const PROGMEM char comm_2[] = "br"; // Bounded rotation
const PROGMEM char comm_3[] = "ir"; // Infinite rotation
const PROGMEM char comm_4[] = "hp"; // Home position
const PROGMEM char commdesc_1[] = "a back-forth motion";
const PROGMEM char commdesc_2[] = "a bounded rotation";
const PROGMEM char commdesc_3[] = "an infinite rotation";
const PROGMEM char commdesc_4[] = "home positioning";
const PROGMEM char direcdesc_1[] = "clockwise";
const PROGMEM char direcdesc_2[] = "counter-clockwise";
const PROGMEM char degree_1[] = "no";
const PROGMEM char degree_2[] = "the lowest degree of";
const PROGMEM char degree_3[] = "the 2nd degree of";
const PROGMEM char degree_4[] = "the 3rd degree of";
const PROGMEM char degree_5[] = "the 4th degree of";
const PROGMEM char degree_6[] = "the 5th degree of";
const PROGMEM char degree_7[] = "the 6th degree of";
const PROGMEM char degree_8[] = "the 7th degree of";
const PROGMEM char degree_9[] = "the 8th degree of";
const PROGMEM char degree_10[] = "the 9th degree of";
const PROGMEM char degree_11[] = "the highest degree of";
const PROGMEM char intensdesc_1[] = "displacement extent";
const PROGMEM char intensdesc_2[] = "rotation speed";
/**
 * Codified joints table (stored in Flash)
 */
const PROGMEM char *const jointTable[] = {joint_1, joint_2, joint_3, joint_4};
/**
 * Joint descriptions table (stored in Flash)
 */
const PROGMEM char *const jointdescTable[] = {jointdesc_1, jointdesc_2, jointdesc_3, jointdesc_4};
/**
 * Codified commands table (stored in Flash)
 */
const PROGMEM char *const commTable[] = {comm_1, comm_2, comm_3};
/**
 * Commands description table (stored in Flash)
 */
const PROGMEM char *const commdescTable[] = {commdesc_1, commdesc_2, commdesc_3};
/**
 * Direction description table (stored in Flash)
 */
const PROGMEM char *const direcdescTable[] = {direcdesc_1, direcdesc_2};
/**
 * Intensity degree table (stored in Flash)
 */
const PROGMEM char *const intensdegreeTable[] = {degree_1, degree_2, degree_3, degree_4, degree_5, degree_6, degree_7, degree_8, degree_9, degree_10, degree_11};
/**
 * Intensity description table (stored in Flash)
 */
const PROGMEM char *const intensdescTable[] = {intensdesc_1, intensdesc_2, intensdesc_2};
char buffer[22];

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

		memcpy(commName, message, sizeof(commName) - sizeof(char));																															// Copying the parameter portion inside message to a single string
		memcpy(targetJoint, message + COMM_NAME_LEN - 1, sizeof(targetJoint) - sizeof(char));																		// Copying the parameter portion inside message to a single string
		memcpy(motionDirec, message + COMM_NAME_LEN + TRG_JOINT_LEN - 2, sizeof(motionDirec) - sizeof(char));										// Copying the parameter portion inside message to a single string
		memcpy(motionIntens, message + COMM_NAME_LEN + TRG_JOINT_LEN + MTN_DIREC_LEN - 3, sizeof(motionIntens) - sizeof(char)); // Copying the parameter portion inside message to a single string
		DEBUG_SERIALprintln("Codified parameters: Command Name = %s \t Target joint = %s \t Motion Direction = %s \t Motion Intensity = %s", commName, targetJoint, motionDirec, motionIntens);

		// Obtaining functions parameters in their expected type
		int jointIndex; // Index of joint inside the Codified joints table
		for (byte i = 0; i < sizeof(jointTable) / sizeof(*jointTable); i++)
		{
			jointIndex = -1; // Assigning an imposible value for an array index in case no joint is found
			strcpy_P(buffer,
							 (char *)pgm_read_word(&(jointTable[i]))); // Operations that copy a string from program memory (Flash) to a
																												 // string in RAM, as seen in: https://www.arduino.cc/reference/en/language/variables/utilities/progmem/
																												 // Extraction of joint code in position i of the Codified Joint Table
			if (strcmp(targetJoint, buffer) == 0)							 // strcmp compares 2 strings. Refer to: https://www.cplusplus.com/reference/cstring/strcmp/
			{
				jointIndex = i;
				break;
			}
		}
		if (jointIndex == -1)
		{
			DEBUG_SERIAL.print(F("Error: Target joint is not registered in program. Registered joints: "));
			for (byte i = 0; i < sizeof(jointTable) / sizeof(*jointTable); i++)
			{
				DEBUG_SERIAL.print("'");
				DEBUG_SERIAL.print(strcpy_P(buffer,(char *)pgm_read_word(&(jointTable[i]))));
				if (i != (sizeof(jointTable) / sizeof(*jointTable) - 1))
				{
					DEBUG_SERIAL.print("', ");
				}
				else
				{
					DEBUG_SERIAL.println("'");
				}
			}
			return;
		}
		byte servoID = jointIndex + 1;
		int direction = atoi(motionDirec);
		if (!(direction == 0 || direction == 1))
		{
			DEBUG_SERIAL.println(F("Error: Motion direction is invalid. Possible values: '0', '1'"));
			return;
		}
		byte intensity = atoi(motionIntens);
		if (!(intensity >= 0 && intensity <= 10))
		{
			DEBUG_SERIAL.println(F("Error: Motion intensity is invalid. Possible values: '00', '01', '02', '03', '04', '05', '06' ,'07', '08', '09', '10'"));
			return;
		}
		int commIndex; // Index of command inside the Codified commands table
		for (byte i = 0; i < sizeof(commTable) / sizeof(*commTable); i++)
		{
			commIndex = -1; // Assigning an imposible value of for an array index in case no command is found
			strcpy_P(buffer,
							 (char *)pgm_read_word(&(commTable[i]))); // Operations that copy a string from program memory (Flash) to a
																												// string in RAM, as seen in: https://www.arduino.cc/reference/en/language/variables/utilities/progmem/
																												// Extraction of command in position i of the Codified commands Table
			if (strcmp(commName, buffer) == 0)								// strcmp compares 2 strings. Refer to: https://www.cplusplus.com/reference/cstring/strcmp/
			{
				commIndex = i;
				break;
			}
		}
		switch (commIndex)
		{
		case -1: // -1 means the no matching command was found in the Commands Table
			//BT_SERIAL.print("n"); // Transmission of decoding result: "n" means "not identified"
			DEBUG_SERIAL.print(F("Error: Command name is not registered in program. Registered commands: "));
			for (byte i = 0; i < sizeof(commTable) / sizeof(*commTable); i++)
			{
				DEBUG_SERIAL.print(F("'"));
				DEBUG_SERIAL.print(strcpy_P(buffer,(char *)pgm_read_word(&(commTable[i]))));
				if (i != (sizeof(commTable) / sizeof(*commTable) - 1))
				{
					DEBUG_SERIAL.print(F("', "));
				}
				else
				{
					DEBUG_SERIAL.println("'");
				}
			}
			break;
		default: // Case in which a matching command was found
			//BT_SERIAL.print("i"); // Transmission of enconding result: "i" means "identified"
			DEBUG_SERIALprintln("Program parameters: commIndex = %d \t servoID = %d \t direction: %d \t intensity: %d", commIndex, servoID, direction, intensity);
			DEBUG_SERIAL.print(F("Decoded command:\r\nPerforming "));
			strcpy_P(buffer, (char *)pgm_read_word(&(commdescTable[commIndex])));
			DEBUG_SERIAL.print(buffer);
			DEBUG_SERIAL.print(F(" on "));
			strcpy_P(buffer, (char *)pgm_read_word(&(jointdescTable[jointIndex])));
			DEBUG_SERIAL.print(buffer);
			DEBUG_SERIAL.print(F(", going first in "));
			strcpy_P(buffer, (char *)pgm_read_word(&(direcdescTable[direction])));
			DEBUG_SERIAL.print(buffer);
			DEBUG_SERIAL.print(F(" direction, with "));
			strcpy_P(buffer, (char *)pgm_read_word(&(intensdegreeTable[intensity])));
			DEBUG_SERIAL.print(buffer);
			DEBUG_SERIAL.print(F(" "));
			strcpy_P(buffer, (char *)pgm_read_word(&(intensdescTable[commIndex])));
			DEBUG_SERIAL.println(buffer);
			functions[commIndex](servoID, direction, intensity);
			break;
		}
	}
}

void setup()
{
	DEBUG_SERIAL.begin(115200); // Initialize the Arduino - Computer communication interface
	// When working besides AltSoftSerial, SoftwareSerial rates must be greater than 10 times the AltSoftSerial rate.
	// Refer to 'Using Both SoftwareSerial and AltSoftSerial' section in: https://www.pjrc.com/teensy/td_libs_AltSoftSerial.html
	BT_SERIAL.begin(9600); // Initialize the Ardunio - Bluetooth Module communication interface
	// Default baud rate of HM-10 module is 9600 bps. Refer to: http://www.dsdtech-global.com/2017/08/hm-10.html
	dxl.begin(1000000); // Initialize Dynamixel communication interface, begin() method receives baudrate as input
	// Default baud rate of Servo AX-12A is 1 000 000 bps. Refer to: https://emanual.robotis.com/docs/en/dxl/ax/ax-12a/#baud-rate
	dxl.setPortProtocolVersion(DXL_PROTOCOL_VERSION);				//Configuring the protocol version of instance
	dxl.writeControlTableItem(STATUS_RETURN_LEVEL, 254, 1); // Broadcasting a writing instruction. Defining that the Status package
	// will only be returned for PING instructions

	DEBUG_SERIAL.println(F("THIS IS THE WIRELESS BLUETOOTH SERVO OPERATION PROGRAM\r\n"
												 "* Connect a device with Bluetooth 4.0 support to the 'DSD TECH' module\r\n"
												 "* End every command with a Carriage return character (0x0d, 13 or '\\r')"));
	DEBUG_SERIALprintln("* Command length: %d", COMM_LEN);
	DEBUG_SERIALprintln("* Length strictness is: %s", onoffChart[LEN_STRICT]);
	DEBUG_SERIAL.println(F("* User can change these values by code-editing COMM_LEN and LEN_STRICT\r\n"
												 "--------------------------\r\n"
												 "* COMMAND STRING STRUCTURE *\r\n"
												 "| COMMAND NAME (2 chars)\t| TARGET JOINT (2 chars)\t| MOTION DIRECTION (1 char)\t| MOTION INTENSITY (2 chars)\t| CARRIAGE RETURN : 0x0d |\r\n"
												 "* PARAMETERS CODIFICATION *\r\n"
												 "| - COMMAND NAME -\t\t- CODE -\t|\t- TARGET JOINT -\t\t- CODE -\t|\t- MOTION DIRECTION -\t\t- CODE -\t|\t\t\t- MOTION INTENSITY -\t\t\t\t- CODE -\t|\r\n"
												 "| Back Forth Motion\t bf(0x6266)\t|\t\t Right Arm\t\t\t ra(0x7261)\t|\t\t\t Clockwise\t\t\t\t\t0(0x30)\t\t|\t\t No motion/Stop motion \t\t\t 00(0x3030)\t|\r\n"
												 "| Bounded Rotation\t br(0x6272)\t|\t\t Left Arm\t\t\t\t la(0x6C61)\t|\t\tCounterclockwise\t\t\t1(0x31)\t\t|\tSmall/Slowest possible motion\t 01(0x3031)\t|\r\n"
												 "| Infinite Rotation\t ir(0x6972)\t|\t\tHead Z-Axis\t\t\t hz(0x687A)\t|\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t|\t\t\t\t\t\t\t...\t\t\t\t\t\t\t\t\t\t...\t\t\t|\r\n"
												 "| Home Position\t\t\t hp(0x6870)\t|\t\tHead X-Axis\t\t\t hx(0x6878)\t|\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t|\tLarge/Fastest possible motion\t 10(0x3130)\t|\r\n"));
	// dxl.writeControlTableItem(TORQUE_ENABLE, 2, 0);
	// dxl.writeControlTableItem(CW_ANGLE_LIMIT, 2, 0);										 // Setting lower limit for the specified motor
	// dxl.writeControlTableItem(CCW_ANGLE_LIMIT, 2, 1023);							// Setting higher limit for the specified motor
	// dxl.writeControlTableItem(TORQUE_ENABLE, 2, 1);
	// tableValue = 1023 * 5 / 10;															// Moving Speed value to write in Control Table field
	// dxl.writeControlTableItem(MOVING_SPEED, 2, tableValue); // Setting the speed in Moving speed field
	// dxl.writeControlTableItem(GOAL_POSITION, 2, 0);																// Performing the starting rotation towards the direction value
	// delay(1000);
	// dxl.writeControlTableItem(GOAL_POSITION, 2, 512);
	// delay(1000);
	// //dxl.writeControlTableItem(GOAL_POSITION, 1, 1023);
	// delay(1000);
	// delay(1000);
	// dxl.writeControlTableItem(GOAL_POSITION, 2, 512);
	// delay(1000);
	// //dxl.writeControlTableItem(GOAL_POSITION, 1, 1023);
	// delay(1000);
	// data = 512;
	// dxl.writeControlTableItem(GOAL_POSITION, 2, data);
	// delay(1000);
	// delay(1000);
	// data = 1023;
	// dxl.writeControlTableItem(GOAL_POSITION, 2, data);
}

void loop()
{
	BT_SERIALgetmessage(LEN_STRICT);
	decodeCommand();
}
