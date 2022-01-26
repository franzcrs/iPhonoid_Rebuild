#ifndef DYNAMIXEL2ARDUINOEXTENSION_H
#define DYNAMIXEL2ARDUINOEXTENSION_H

#include "Arduino.h"
#include "Dynamixel2Arduino.h"

class Dynamixel2ArduinoExtension : virtual public Dynamixel2Arduino
{
public:
  /**
     * @brief Class constructor
     * @code
     * const int DXL_DIR_PIN = 2;
     * Dynamixel2ArduinoExtension dxl(Serial1, DXL_DIR_PIN);
     * @endcode
     * @param port The HardwareSerial port you want to use on the board to communicate with DYNAMIXELs.
     * @param dir_pin Directional pins for using half-duplex communication. -1 uses full duplex. (default : -1)
     */
  Dynamixel2ArduinoExtension(HardwareSerial& port, int dir_pin);
  /**
     * @brief API for registering in the DYNAMIXEL memory a writing instruction to execute later
     * @code
     * const int DXL_DIR_PIN = 2;
     * Dynamixel2Arduino dxl(Serial1, DXL_DIR_PIN);
     * dxl.regwriteControlTableItem(TORQUE_ENABLE, 1, 1);
     * @endcode
     * @param item_idx DYNAMIXEL Actuator's control table item's index.
     *    For each index, replace the name of the control table item in the e-manual with capital letters and replace the space with an underscore (_).
     *    It is defined as 'enum ControlTableItem' in actuator.h
     * @param id DYNAMIXEL Actuator's ID.
     * @param data The data you want to write. Only the data size allowed by the address is applied.
     * @param timeout A timeout waiting for a response to a data transfer.
     * @return It returns true(1) on success, false(0) on failure.
     */
  bool regwriteControlTableItem(uint8_t item_idx, uint8_t id, int32_t data, uint32_t timeout = 100);

private:
  DYNAMIXEL::SerialPortHandler *p_dxl_port_;
  uint8_t model_number_idx_[254];
  uint8_t model_number_idx_last_index_;
  uint16_t getModelNumberFromTable(uint8_t id);
  bool regwriteControlTableItem(uint16_t model_num, uint8_t item_idx, uint8_t id, int32_t data, uint32_t timeout);
};

#endif