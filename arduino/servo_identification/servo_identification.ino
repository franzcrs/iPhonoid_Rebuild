/**
 * @file servo_identification.ino
 * @author Franz Chuquirachi (@franzcrs)
 * @brief Performs identification of servos connected to Dynamixel Shield of the half-built iPhonoid through a display of motion
 * @version 0.2
 * @date 2021-12-06
 * 
 * @copyright Copyright (c) 2021
 * 
 */

#include <DynamixelShield.h>
#include <stdarg.h>

/**
 * DYNAMIXELShield uses digital pins (0,1) to communicate with the servos.
 * These are the same pins as in Arduino Uno/Mega, used for the usb communication.
 * Therefore, the interface 'Serial' (pins (0,1)) cannot be used with normality.
 * And another serial interface needs to be created.
 * For other boards, pins (0,1) are not connected to the usb connector.
 * For detailed information refer to:
 * https://www.arduino.cc/reference/en/language/functions/communication/serial/
 * https://emanual.robotis.com/docs/en/parts/interface/dynamixel_shield/
 * */
#if defined(ARDUINO_AVR_UNO) || defined(ARDUINO_AVR_MEGA2560)
#include <SoftwareSerial.h>
SoftwareSerial soft_serial(7, 8); // New Arduino/DYNAMIXELShield UART pins
#define DEBUG_SERIAL soft_serial
#elif defined(ARDUINO_SAM_DUE) || defined(ARDUINO_SAM_ZERO)
#define DEBUG_SERIAL SerialUSB
#else
#define DEBUG_SERIAL Serial
#endif

const byte MAX_ID = 4;									// Max id number to identify
const float DXL_PROTOCOL_VERSION = 1.0; // Servos AX-12A use protocol 1.0
// Refer to Compatibility Table in: https://emanual.robotis.com/docs/en/dxl/protocol1/

DynamixelShield dxl;							// Declaring an instance of DynamixelShield
using namespace ControlTableItem; // Required namespace to use Controltable item names

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

void setup()
{
	DEBUG_SERIAL.begin(115200); // Initialize the Arduino - Computer communication interface
	dxl.begin(1000000);					// Initialize Dynamixel communication interface, begin() method receives baudrate as input
	// Default baud rate of Servo AX-12A is 1 000 000 bps, refer to: https://emanual.robotis.com/docs/en/dxl/ax/ax-12a/#baud-rate
	dxl.setPortProtocolVersion(DXL_PROTOCOL_VERSION); //Configuring the protocol version of instance
}

void loop()
{
	// TODO: Make an interactive interface through serial monitor
	static byte DXL_ID = 1;
	// Un-comment one of the following function depending on your goal
	// verifyServo(DXL_ID); // Displays verification of existance of servo in the DEBUG_SERIAL interface
	indentifyServo(DXL_ID); // Allows user to identify a servo among many by performing a motion on the current id count
	DXL_ID++;
	if (DXL_ID > MAX_ID)
	{
		DXL_ID = 1;
	}
	loadingPattern(3);
}

/**
 * Chart of Servo IDs and its driven joint
 * 1 -- RIGHT ARM
 * 2 -- LEFT ARM
 * 3 -- NECK YAW
 * 4 -- NECK PITCH
 * 
 */