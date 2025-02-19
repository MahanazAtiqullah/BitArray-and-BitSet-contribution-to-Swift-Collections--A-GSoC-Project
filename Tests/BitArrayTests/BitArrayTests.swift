//
//  File.swift
//  
//
//  Created by Mahanaz Atiqullah on 7/27/21.
//

import XCTest
import CollectionsTestSupport
@testable import BitArrayModule

final class BitArrayTest: CollectionTestCase {
  
  typealias WORD = BitArray.WORD
  let sizes: [Int] = _getSizes(BitArray.WORD.bitWidth)
  
  func testEmptyInit() {
    let emptyBitArray = BitArray()
    expectEqual(emptyBitArray.storage, [])
    expectEqual(emptyBitArray.excess, 0)
    expectEqual(emptyBitArray.count, 0)
    expectEqual(emptyBitArray.startIndex, 0)
    expectEqual(emptyBitArray.endIndex, 0)
    expectEqual(emptyBitArray, emptyBitArray)
  }
  
  func testSequenceInitializer() {
    withSomeUsefulBoolArrays("boolArray", ofSizes: sizes, ofUnitBitWidth: BitArray.WORD.bitWidth) { boolArray in
      let testBitArray: BitArray = BitArray(boolArray)
      expectEqual(Array(testBitArray), boolArray)
      expectEqual(testBitArray.count, boolArray.count)
      expectEqual(testBitArray.endIndex, boolArray.count)
      expectEqual(testBitArray.excess, WORD(boolArray.count%WORD.bitWidth))
    }
  }
  
  func testExpressibleByArrayLiteralAndArrayLiteralInit() {
    withSomeUsefulBoolArrays("boolArray", ofSizes: sizes, ofUnitBitWidth: BitArray.WORD.bitWidth) { boolArray in
      let testBitArray = BitArray(boolArray)
      expectEqual(Array(testBitArray), boolArray)
    }
    
    // Using manually created Bool Arrays
    let testBitArray1: BitArray = []
    expectEqual(Array(testBitArray1), [])
    expectEqual(testBitArray1.excess, WORD(testBitArray1.count%WORD.bitWidth))
    expectEqual(testBitArray1.count, 0)
    
    let testBitArray2: BitArray = [true]
    expectEqual(Array(testBitArray2), [true])
    expectEqual(testBitArray2.storage, [1])
    expectEqual(testBitArray2.excess, WORD(testBitArray2.count%WORD.bitWidth))
    expectEqual(testBitArray2.count, 1)
    
    let testBitArray3: BitArray = [false]
    expectEqual(Array(testBitArray3), [false])
    expectEqual(testBitArray3.storage, [0])
    expectEqual(testBitArray3.excess, WORD(testBitArray3.count%WORD.bitWidth))
    expectEqual(testBitArray3.count, 1)
    
    let testBitArray4: BitArray = [true, true, true, true, true, true, true, true]
    expectEqual(Array(testBitArray4), [true, true, true, true, true, true, true, true])
    expectEqual(testBitArray4.storage, [255])
    expectEqual(testBitArray4.excess, WORD(testBitArray4.count%WORD.bitWidth))
    expectEqual(testBitArray4.count, 8)
    
    let testBitArray4B: BitArray = [true, true, true, true, true, true, true, true, true]
    expectEqual(Array(testBitArray4B), [true, true, true, true, true, true, true, true, true])
    expectEqual(testBitArray4B.excess, WORD(testBitArray4B.count%WORD.bitWidth))
    expectEqual(testBitArray4B.count, 9)
    
    let testBitArray5: BitArray = [false, false, false, false, false, false, false, false]
    expectEqual(Array(testBitArray5), [false, false, false, false, false, false, false, false])
    expectEqual(testBitArray5.storage, [0])
    expectEqual(testBitArray5.excess, WORD(testBitArray5.count%WORD.bitWidth))
    expectEqual(testBitArray5.count, 8)
    
    let testBitArray5B: BitArray = [false, false, false, false, false, false, false, false, false]
    expectEqual(Array(testBitArray5B), [false, false, false, false, false, false, false, false, false])
    expectEqual(testBitArray5B.excess, WORD(testBitArray5B.count%WORD.bitWidth))
    expectEqual(testBitArray5B.count, 9)
    
    let testBitArray6: BitArray = [true, false, true, false, false, false, true]
    expectEqual(Array(testBitArray6), [true, false, true, false, false, false, true])
    expectEqual(testBitArray6.storage, [69])
    expectEqual(testBitArray6.excess, WORD(testBitArray6.count%WORD.bitWidth))
    expectEqual(testBitArray6.count, 7)
  }
  
  func testRepeatingInit() {
    for count in 0...3*(WORD.bitWidth) {
      let trueArray = Array(repeating: true, count: count)
      let falseArray = Array(repeating: false, count: count)
      
      let trueBitArray = BitArray(repeating: true, count: count)
      let falseBitArray = BitArray(repeating: false, count: count)
      
      let repeatCount = (count%(WORD.bitWidth) == 0) ? Int(count/(WORD.bitWidth)) : Int(count/(WORD.bitWidth)) + 1
      let expectedFalseStorage: [WORD] = Array(repeating: 0, count: repeatCount)
      var expectedTrueStorage: [WORD] = Array(repeating: WORD.max, count: repeatCount)
      if (count%(WORD.bitWidth) != 0) {
        expectedTrueStorage.removeLast()
        let remaining = count%(WORD.bitWidth)
        var valueToAdd: WORD = 0
        for shift in 0..<remaining {
          valueToAdd += (WORD(1) << shift)
        }
        expectedTrueStorage.append(valueToAdd)
      }
      let expectedExcess: WORD = WORD(count%WORD.bitWidth)
      
      expectEqual(Array(trueBitArray), trueArray)
      expectEqual(Array(falseBitArray), falseArray)
      expectEqual(trueBitArray.storage, expectedTrueStorage)
      expectEqual(falseBitArray.storage, expectedFalseStorage)
      expectEqual(trueBitArray.excess, expectedExcess)
      expectEqual(falseBitArray.excess, expectedExcess)
      expectEqual(trueBitArray.count, trueArray.count)
      expectEqual(falseBitArray.count, falseArray.count)
    }
  }
  
  func testBitSetInit() {
    withSomeUsefulBoolArrays("boolArray", ofSizes: sizes, ofUnitBitWidth: WORD.bitWidth) { bitArrayLayout in
      withTheirBitSetLayout("bitSet", ofLayout: bitArrayLayout) { bitSetLayout in
        let bitArray = BitArray(bitArrayLayout)
        let bitSet = BitSet(bitSetLayout)
        let bitArrayFromSet = BitArray(bitSet)
        
        // only need to see if true values are in correct location
        if(bitArray.storage.count > bitArrayFromSet.storage.count) {
          for index in 0..<bitArrayFromSet.storage.count {
            expectEqual(bitArray.storage[index], bitArrayFromSet.storage[index])
          }
          for index in bitArrayFromSet.storage.count..<bitArray.storage.count {
            expectEqual(bitArray.storage[index], 0)
          }
        } else if (bitArray.storage.count < bitArrayFromSet.storage.count){
          for index in 0..<bitArray.storage.count {
            expectEqual(bitArrayFromSet.storage[index], bitArray.storage[index])
          }
          for index in bitArray.storage.count..<bitArrayFromSet.storage.count {
            expectEqual(bitArrayFromSet.storage[index], 0)
          }
        }
      }
    }
  }
  
  func testAppend() { // depends on initializer tests passing
    withSomeUsefulBoolArrays("bitArray", ofSizes: sizes, ofUnitBitWidth: WORD.bitWidth) { layout in
      var bitArray = BitArray(layout)
      var bitArrayInverse = BitArray(layout)
      
      var layoutCopy = layout
      var layoutCopyInverse = layout
      
      var value = true
      for _ in 0...(2*BitArray.WORD.bitWidth+1) {
        
        bitArray.append(value)
        bitArrayInverse.append(!value)
        layoutCopy.append(value)
        layoutCopyInverse.append(!value)
        
        expectEqual(Array(bitArray), layoutCopy)
        expectEqual(bitArray.count, layoutCopy.count)
        
        expectEqual(Array(bitArrayInverse), layoutCopyInverse)
        expectEqual(bitArrayInverse.count, layoutCopyInverse.count)
        
        value = Bool.random()
      }
    }
  }
  
  func testRemoveFirst() {
    withSomeUsefulBoolArrays("bitArray", ofSizes: sizes, ofUnitBitWidth: WORD.bitWidth) { layout in
      var bitArray = BitArray(layout)
      var layoutCopy = layout
      
      
      // remove every bool until end
      for i in 0..<bitArray.endIndex {
        
        expectEqual(bitArray.removeFirst(), layout[i])
        layoutCopy.removeFirst()
        
        expectEqual(Array(bitArray), layoutCopy)
        expectEqual(bitArray.count, layoutCopy.count)
        expectEqual(bitArray.count, (layout.count-i-1))
      }
    }
  }
  
  func testRemoveFirstRange() {
    withSomeUsefulBoolArrays("bitArray", ofSizes: sizes, ofUnitBitWidth: WORD.bitWidth) { layout in
      if (layout.count == 0) {
        // cannot test empty array without tests crashing
      } else {
        var bitArrayForReuse = BitArray(layout)
        var layoutCopyForReuse = layout
        
        
        for removeAmount in 1..<layout.count {
          bitArrayForReuse.removeFirst(removeAmount)
          layoutCopyForReuse.removeFirst(removeAmount)
          
          expectEqual(Array(bitArrayForReuse), layoutCopyForReuse)
          expectEqual(bitArrayForReuse.count, layoutCopyForReuse.count)
          expectEqual(bitArrayForReuse.count, (layout.count-removeAmount))
          
          bitArrayForReuse = BitArray(layout)
          layoutCopyForReuse = layout
        }
      }
    }
  }
  
  func testRemoveLast() {
    withSomeUsefulBoolArrays("bitArray", ofSizes: sizes, ofUnitBitWidth: WORD.bitWidth) { layout in
      var bitArray = BitArray(layout)
      var layoutCopy = layout
      
      
      // remove every bool until end
      for i in 0..<bitArray.endIndex {
        
        expectEqual(bitArray.removeLast(), layout[layout.endIndex-i-1])
        layoutCopy.removeLast()
        
        expectEqual(Array(bitArray), layoutCopy)
        expectEqual(bitArray.count, layoutCopy.count)
        expectEqual(bitArray.count, (layout.count-i-1))
      }
    }
  }
  
  func testRemoveLastRange() {
    withSomeUsefulBoolArrays("bitArray", ofSizes: sizes, ofUnitBitWidth: WORD.bitWidth) { layout in
      if (layout.count == 0) {
        // cannot test empty array without tests crashing
      } else {
        var bitArrayForReuse = BitArray(layout)
        var layoutCopyForReuse = layout
        
        
        for removeAmount in 1..<layout.count {
          bitArrayForReuse.removeLast(removeAmount)
          layoutCopyForReuse.removeLast(removeAmount)
          
          expectEqual(Array(bitArrayForReuse), layoutCopyForReuse)
          expectEqual(bitArrayForReuse.count, layoutCopyForReuse.count)
          expectEqual(bitArrayForReuse.count, (layout.count-removeAmount))
          
          bitArrayForReuse = BitArray(layout)
          layoutCopyForReuse = layout
        }
      }
    }
  }
  
  func testRemoveAt() {
    withSomeUsefulBoolArrays("bitArray", ofSizes: sizes, ofUnitBitWidth: WORD.bitWidth) { layout in
      var bitArrayForReuse = BitArray(layout)
      var layoutCopyForReuse = layout
      
      for removeIndex in 0..<layout.count {
        expectEqual(bitArrayForReuse.remove(at: removeIndex), layout[removeIndex])
        layoutCopyForReuse.remove(at: removeIndex)
        
        expectEqual(Array(bitArrayForReuse), layoutCopyForReuse)
        expectEqual(bitArrayForReuse.count, layoutCopyForReuse.count)
        expectEqual(bitArrayForReuse.count, (layout.count-1))
        
        bitArrayForReuse = BitArray(layout)
        layoutCopyForReuse = layout
      }
      
    }
  }
  
  func testRemoveAll() {
    withSomeUsefulBoolArrays("bitArray", ofSizes: sizes, ofUnitBitWidth: WORD.bitWidth) { layout in
      var bitArray = BitArray(layout)
      var layoutCopy = layout
      
      bitArray.removeAll()
      layoutCopy.removeAll()
      
      expectEqual(bitArray.storage.count, 0)
      expectEqual(bitArray.storage, [])
      expectEqual(bitArray.count, 0)
      expectEqual(bitArray.excess, 0)
      expectEqual(Array(bitArray), layoutCopy)
    }
  }
  
  func testFirstTrueIndex() {
    withSomeUsefulBoolArrays("bitArray", ofSizes: sizes, ofUnitBitWidth: WORD.bitWidth) { layout in
      let bitArray = BitArray(layout)
      expectEqual(bitArray.firstTrue(), layout.firstIndex(where: {$0 == true}))
    }
  }
  
  func testLastTrueIndex() {
    withSomeUsefulBoolArrays("bitArray", ofSizes: sizes, ofUnitBitWidth: WORD.bitWidth) { layout in
      let bitArray = BitArray(layout)
      expectEqual(bitArray.lastTrue(), layout.lastIndex(where: {$0 == true}))
    }
  }
  
  func testBitwiseOr() {
    withSomeUsefulBoolArrays("firstBitArray", ofSizes: sizes, ofUnitBitWidth: WORD.bitWidth) { firstLayout in
      withSomeUsefulBoolArrays("secondBitArray", ofSizes: sizes, ofUnitBitWidth: WORD.bitWidth) { secondLayout in
        var firstBitArray = BitArray(firstLayout)
        let secondBitArray = BitArray(secondLayout)
        if (firstLayout.count == secondLayout.count) {
          var expectedArray: [Bool] = []
          for index in 0..<firstLayout.endIndex {
            let value = (firstLayout[index] || secondLayout[index])
            expectedArray.append(value)
          }
          
          // test non-form
          let resultBitArray = firstBitArray.bitwiseOr(secondBitArray)
          expectEqual(Array(resultBitArray), expectedArray)
          
          //test form
          firstBitArray.formBitwiseOr(secondBitArray)
          expectEqual(firstBitArray, resultBitArray)
          expectEqual(Array(firstBitArray), expectedArray)
        }
      }
    }
  }
  
  func testBitwiseOrOperators() {
    withSomeUsefulBoolArrays("firstBitArray", ofSizes: sizes, ofUnitBitWidth: WORD.bitWidth) { firstLayout in
      withSomeUsefulBoolArrays("secondBitArray", ofSizes: sizes, ofUnitBitWidth: WORD.bitWidth) { secondLayout in
        var firstBitArray = BitArray(firstLayout)
        let secondBitArray = BitArray(secondLayout)
        if (firstLayout.count == secondLayout.count) {
          var expectedArray: [Bool] = []
          for index in 0..<firstLayout.endIndex {
            let value = (firstLayout[index] || secondLayout[index])
            expectedArray.append(value)
          }
          
          // test non-form
          let resultBitArray = firstBitArray | secondBitArray
          expectEqual(Array(resultBitArray), expectedArray)
          
          //test form
          firstBitArray |= secondBitArray
          expectEqual(firstBitArray, resultBitArray)
          expectEqual(Array(firstBitArray), expectedArray)
        }
      }
    }
  }
  
  func testBitwiseAnd() {
    withSomeUsefulBoolArrays("firstBitArray", ofSizes: sizes, ofUnitBitWidth: WORD.bitWidth) { firstLayout in
      withSomeUsefulBoolArrays("secondBitArray", ofSizes: sizes, ofUnitBitWidth: WORD.bitWidth) { secondLayout in
        var firstBitArray = BitArray(firstLayout)
        let secondBitArray = BitArray(secondLayout)
        if (firstLayout.count == secondLayout.count) {
          var expectedArray: [Bool] = []
          for index in 0..<firstLayout.endIndex {
            let value = (firstLayout[index] && secondLayout[index])
            expectedArray.append(value)
          }
          
          // test non-form
          let resultBitArray = firstBitArray.bitwiseAnd(secondBitArray)
          expectEqual(Array(resultBitArray), expectedArray)
          
          //test form
          firstBitArray.formBitwiseAnd(secondBitArray)
          expectEqual(firstBitArray, resultBitArray)
          expectEqual(Array(firstBitArray), expectedArray)
        }
      }
    }
  }
  
  func testBitwiseAndOperators() {
    withSomeUsefulBoolArrays("firstBitArray", ofSizes: sizes, ofUnitBitWidth: WORD.bitWidth) { firstLayout in
      withSomeUsefulBoolArrays("secondBitArray", ofSizes: sizes, ofUnitBitWidth: WORD.bitWidth) { secondLayout in
        var firstBitArray = BitArray(firstLayout)
        let secondBitArray = BitArray(secondLayout)
        if (firstLayout.count == secondLayout.count) {
          var expectedArray: [Bool] = []
          for index in 0..<firstLayout.endIndex {
            let value = (firstLayout[index] && secondLayout[index])
            expectedArray.append(value)
          }
          
          // test non-form
          let resultBitArray = firstBitArray & secondBitArray
          expectEqual(Array(resultBitArray), expectedArray)
          
          //test form
          firstBitArray &= secondBitArray
          expectEqual(firstBitArray, resultBitArray)
          expectEqual(Array(firstBitArray), expectedArray)
        }
      }
    }
  }
  
  func testBitwiseXor() {
    withSomeUsefulBoolArrays("firstBitArray", ofSizes: sizes, ofUnitBitWidth: WORD.bitWidth) { firstLayout in
      withSomeUsefulBoolArrays("secondBitArray", ofSizes: sizes, ofUnitBitWidth: WORD.bitWidth) { secondLayout in
        var firstBitArray = BitArray(firstLayout)
        let secondBitArray = BitArray(secondLayout)
        if (firstLayout.count == secondLayout.count) {
          var expectedArray: [Bool] = []
          for index in 0..<firstLayout.endIndex {
            let value = (firstLayout[index] != secondLayout[index])
            expectedArray.append(value)
          }
          
          // test non-form
          let resultBitArray = firstBitArray.bitwiseXor(secondBitArray)
          expectEqual(Array(resultBitArray), expectedArray)
          
          //test form
          firstBitArray.formBitwiseXor(secondBitArray)
          expectEqual(firstBitArray, resultBitArray)
          expectEqual(Array(firstBitArray), expectedArray)
        }
      }
    }
  }
  
  func testBitwiseXorOperators() {
    withSomeUsefulBoolArrays("firstBitArray", ofSizes: sizes, ofUnitBitWidth: WORD.bitWidth) { firstLayout in
      withSomeUsefulBoolArrays("secondBitArray", ofSizes: sizes, ofUnitBitWidth: WORD.bitWidth) { secondLayout in
        var firstBitArray = BitArray(firstLayout)
        let secondBitArray = BitArray(secondLayout)
        if (firstLayout.count == secondLayout.count) {
          var expectedArray: [Bool] = []
          for index in 0..<firstLayout.endIndex {
            let value = (firstLayout[index] != secondLayout[index])
            expectedArray.append(value)
          }
          
          // test non-form
          let resultBitArray = firstBitArray ^ secondBitArray
          expectEqual(Array(resultBitArray), expectedArray)
          
          //test form
          firstBitArray ^= secondBitArray
          expectEqual(firstBitArray, resultBitArray)
          expectEqual(Array(firstBitArray), expectedArray)
        }
      }
    }
  }
  
  func testBitwiseNot() {
    withSomeUsefulBoolArrays("boolArray", ofSizes: sizes, ofUnitBitWidth: WORD.bitWidth) { layout in
      var bitArray = BitArray(layout)
      var bitArrayCopy = bitArray
      var expectedArray: [Bool] = []
      
      for value in layout {
        expectedArray.append(!value)
      }
      let newCopy = bitArray.bitwiseNot()
      bitArray.formBitwiseNot()
      bitArrayCopy = ~bitArrayCopy
      
      
      expectEqual(Array(bitArray), expectedArray)
      expectEqual(BitArray(expectedArray), bitArray)
      
      expectEqual(Array(newCopy), expectedArray)
      expectEqual(BitArray(expectedArray), newCopy)
      
      expectEqual(Array(bitArrayCopy), expectedArray)
      expectEqual(BitArray(expectedArray), bitArrayCopy)
      expectEqual(bitArray, newCopy)
    }
  }
  
  func testIndexBefore() {
    withSomeUsefulBoolArrays("boolArray", ofSizes: sizes, ofUnitBitWidth: WORD.bitWidth) { layout in
      let bitArray = BitArray(layout)
      
      for _ in bitArray.reversed() {
        // Just making sure it runs should suffice
      }
      
      expectEqual(Array(bitArray.reversed()), layout.reversed())
    }
  }
  
  func testEqualAfterModification() {
    var bitArray = [true, false, true]
    let bitArrayCopy = bitArray
    XCTAssertEqual(bitArray, bitArrayCopy)
    bitArray.removeLast()
    bitArray.append(true)
    XCTAssertEqual(bitArray, bitArrayCopy)
      
    bitArray.append(true)
    bitArray.remove(at: bitArray.endIndex-1)
    XCTAssertEqual(bitArray, bitArrayCopy)
  }
}
