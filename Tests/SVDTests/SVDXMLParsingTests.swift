//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift MMIO open source project
//
// Copyright (c) 2026 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import Foundation
import SVD
import Testing

struct SVDXMLParsingTests {
  @Test(arguments: [
    ("", ""),
    ("plain text", "plain text"),
    ("A &amp; B", "A & B"),
    ("&lt;value&gt;", "<value>"),
    ("A &#38; B", "A & B"),
    ("A &#x26; B", "A & B"),
    ("before<![CDATA[<inside>]]>after", "before<inside>after"),
    ("café &amp; 雪", "café & 雪"),
  ])
  func decodeDescription(xml: String, expected: String) throws {
    let data = Data(
      """
      <device>
        <name>TestDevice</name>
        <description>\(xml)</description>
        <addressUnitBits>8</addressUnitBits>
        <width>32</width>
        <peripherals></peripherals>
      </device>
      """.utf8)
    let device = try SVDDevice(data: data)
    #expect(device.description == expected)
  }

  @Test func decodeDescriptionsInSeparateElements() throws {
    let data = Data(
      """
      <device>
        <name>TestDevice</name>
        <description>A &amp; B</description>
        <addressUnitBits>8</addressUnitBits>
        <width>32</width>
        <peripherals>
          <peripheral>
            <name>TestPeripheral</name>
            <description>C &amp; D</description>
            <baseAddress>0</baseAddress>
          </peripheral>
        </peripherals>
      </device>
      """.utf8)
    let device = try SVDDevice(data: data)
    #expect(device.description == "A & B")
    #expect(device.peripherals.peripheral.first?.description == "C & D")
  }
}
