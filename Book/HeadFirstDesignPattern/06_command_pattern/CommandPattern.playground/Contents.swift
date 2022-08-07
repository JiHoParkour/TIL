import UIKit

/// 커맨드 프로토콜
protocol Command {
    func execute()
    func undo()
}

/// 구체 커맨드
class LightOnCommand: Command {
    var lightReceiver: LightReceiver!
    
    init (lightReceiver: LightReceiver) {
        self.lightReceiver = lightReceiver
    }
    
    func execute() {
        lightReceiver.on()
    }
    
    func undo() { }
}

class LightOffCommand: Command {
    var lightReceiver: LightReceiver
    
    init (lightReceiver: LightReceiver) {
        self.lightReceiver = lightReceiver
    }
    
    func execute() {
        lightReceiver.off()
    }
    
    func undo() { }
}

/// 인보커
class Invoker {
    var command: Command?
    
    func setCommand(command: Command) {
        self.command = command
    }
    
    func doSomethingCommandKnow() {
        command?.execute()
    }
}


/// 리시버
class LightReceiver {
    func on() {
        print("조명을 켰습니다.")
    }
    
    func off() {
        print("조명을 껐습니다.")
    }
}

/// 커맨드를 한 개 가질 수 있는 간단한 인보커
let lightReceiver = LightReceiver()
let lightOnCommand = LightOnCommand(lightReceiver: lightReceiver)
let invoker = Invoker()
invoker.setCommand(command: lightOnCommand)
invoker.doSomethingCommandKnow()


class MultiSlotRemoteController {
    var onCommands: [Command]
    var offCommands: [Command]
    var undoCommand: Command
    init() {
        
        let noCommand = NoCommand()
        onCommands = [Command](repeating: noCommand, count: 7)
        offCommands = [Command](repeating: noCommand, count: 7)
        undoCommand = noCommand
    }
    
    func setCommand(slotNum: Int, onCommand: Command, offCommand: Command) {
        onCommands[slotNum] = onCommand
        offCommands[slotNum] = offCommand
    }
    
    func onButtonWasTapped(slotNum: Int) {
        onCommands[slotNum].execute()
        undoCommand = onCommands[slotNum]
    }
    
    func offButtonWasTapped(slotNum: Int) {
        offCommands[slotNum].execute()
        undoCommand = offCommands[slotNum]
    }
    
    func checkSlotState() {
        for i in 0..<onCommands.count {
            print("slot number [\(i)] / on Command is\(onCommands[i].self) / off Command is\(offCommands[i].self)")
        }
        print("undo slot is \(undoCommand.self)")
    }
    
    func undoButtonWasTapped() {
        undoCommand.undo()
    }
}

class NoCommand: Command {
    func execute() {
        
    }
    
    func undo() {
        
    }
}

/// 커맨드를 여러 개 가지고 있는 멀티슬롯리코컨 인보커
let lightOffCommand = LightOffCommand(lightReceiver: lightReceiver)
let multiSlotRemoteController = MultiSlotRemoteController()
multiSlotRemoteController.setCommand(slotNum: 0, onCommand: lightOnCommand, offCommand: lightOffCommand)

multiSlotRemoteController.onButtonWasTapped(slotNum: 0)
multiSlotRemoteController.offButtonWasTapped(slotNum: 0)


/// 작업 취소 기능을 위한 커맨드와 리시버
class AirConditionerOnCommand: Command {
    let airConditionerReceiver: AirConditionerReceiver
    
    init(airConditionerReceiver: AirConditionerReceiver) {
        self.airConditionerReceiver = airConditionerReceiver
    }
    
    func execute() {
        airConditionerReceiver.on()
    }
    
    func undo() {
        airConditionerReceiver.off()
    }
}

class AirConditionerOffCommand: Command {
    let airConditionerReceiver: AirConditionerReceiver
    
    init(airConditionerReceiver: AirConditionerReceiver) {
        self.airConditionerReceiver = airConditionerReceiver
    }
    
    func execute() {
        airConditionerReceiver.off()
    }
    
    func undo() {
        airConditionerReceiver.on()
    }
}

class AirConditionerReceiver {
    func on() {
        print("에어컨을 켰습니다.")
    }
    
    func off() {
        print("에어컨을 껐습니다.")
    }
}

let airConditionerReceiver = AirConditionerReceiver()
let airConditionerOnCommand = AirConditionerOnCommand(airConditionerReceiver: airConditionerReceiver)
let airConditionerOffCommand = AirConditionerOffCommand(airConditionerReceiver: airConditionerReceiver)
multiSlotRemoteController.setCommand(slotNum: 1, onCommand: airConditionerOnCommand, offCommand: airConditionerOffCommand)


multiSlotRemoteController.onButtonWasTapped(slotNum: 1)
multiSlotRemoteController.undoButtonWasTapped()

multiSlotRemoteController.offButtonWasTapped(slotNum: 1)
multiSlotRemoteController.undoButtonWasTapped()
multiSlotRemoteController.undoButtonWasTapped()


enum FanSpeed: Int {
    case high = 3
    case medium = 2
    case low = 1
    case off = 0
}

///작업취소 기능을 상태와 함께 구현하기
class CeilingFanReceiver {
    
    var speed: FanSpeed
    
    init() {
        self.speed = FanSpeed.off
    }
    
    func high() {
        speed = FanSpeed.high
        print("선풍기 풍속을 high로 설정합니다.")
    }
    
    func medium() {
        speed = FanSpeed.medium
        print("선풍기 풍속을 medium으로 설정합니다.")
    }
    
    func low() {
        speed = FanSpeed.low
        print("선풍기 풍속을 low로 설정합니다.")
    }
    
    func off() {
        speed = FanSpeed.off
        print("선풍기 작동을 중지합니다.")
    }
    
    func getSpeed() -> FanSpeed {
        return speed
    }
    
}


class CeilingFanHighCommand: Command {
    
    let ceilingFanReceiver: CeilingFanReceiver
    var prevSpeed: FanSpeed
    
    init (ceilingFanReceiver: CeilingFanReceiver) {
        self.ceilingFanReceiver = ceilingFanReceiver
        self.prevSpeed = FanSpeed.off
    }
    
    func execute() {
        prevSpeed = ceilingFanReceiver.getSpeed()
        ceilingFanReceiver.high()
    }
    
    func undo() {
        switch prevSpeed {
        case .high:
            ceilingFanReceiver.high()
        case .medium:
            ceilingFanReceiver.medium()
        case .low:
            ceilingFanReceiver.low()
        case .off:
            ceilingFanReceiver.off()
            
        }
    }
}

class CeilingFanMediumCommand: Command {
    
    let ceilingFanReceiver: CeilingFanReceiver
    var prevSpeed: FanSpeed
    
    init (ceilingFanReceiver: CeilingFanReceiver) {
        self.ceilingFanReceiver = ceilingFanReceiver
        self.prevSpeed = FanSpeed.off
    }
    
    func execute() {
        prevSpeed = ceilingFanReceiver.getSpeed()
        ceilingFanReceiver.medium()
    }
    
    func undo() {
        switch prevSpeed {
        case .high:
            ceilingFanReceiver.high()
        case .medium:
            ceilingFanReceiver.medium()
        case .low:
            ceilingFanReceiver.low()
        case .off:
            ceilingFanReceiver.off()
            
        }
    }
}

class CeilingFanLowCommand: Command {
    
    let ceilingFanReceiver: CeilingFanReceiver
    var prevSpeed: FanSpeed
    
    init (ceilingFanReceiver: CeilingFanReceiver) {
        self.ceilingFanReceiver = ceilingFanReceiver
        self.prevSpeed = FanSpeed.off
    }
    
    func execute() {
        prevSpeed = ceilingFanReceiver.getSpeed()
        ceilingFanReceiver.low()
    }
    
    func undo() {
        switch prevSpeed {
        case .high:
            ceilingFanReceiver.high()
        case .medium:
            ceilingFanReceiver.medium()
        case .low:
            ceilingFanReceiver.low()
        case .off:
            ceilingFanReceiver.off()
            
        }
    }
}


class CeilingFanOffCommand: Command {
    
    let ceilingFanReceiver: CeilingFanReceiver
    var prevSpeed: FanSpeed
    
    init (ceilingFanReceiver: CeilingFanReceiver) {
        self.ceilingFanReceiver = ceilingFanReceiver
        self.prevSpeed = FanSpeed.off
    }
    
    func execute() {
        prevSpeed = ceilingFanReceiver.getSpeed()
        ceilingFanReceiver.off()
    }
    
    func undo() {
        switch prevSpeed {
        case .high:
            ceilingFanReceiver.high()
        case .medium:
            ceilingFanReceiver.medium()
        case .low:
            ceilingFanReceiver.low()
        case .off:
            ceilingFanReceiver.off()
            
        }
    }
}

let ceilingFanReceiver = CeilingFanReceiver()
let ceilingFanHighCommand = CeilingFanHighCommand(ceilingFanReceiver: ceilingFanReceiver)
let ceilingFanMediumCommand = CeilingFanMediumCommand(ceilingFanReceiver: ceilingFanReceiver)
let ceilingFanLowCommand = CeilingFanLowCommand(ceilingFanReceiver: ceilingFanReceiver)
let ceilingFanOffCommand = CeilingFanOffCommand(ceilingFanReceiver: ceilingFanReceiver)
multiSlotRemoteController.setCommand(slotNum: 2, onCommand: ceilingFanHighCommand, offCommand: ceilingFanOffCommand)
multiSlotRemoteController.setCommand(slotNum: 3, onCommand: ceilingFanMediumCommand, offCommand: ceilingFanOffCommand)
multiSlotRemoteController.setCommand(slotNum: 4, onCommand: ceilingFanLowCommand, offCommand: ceilingFanOffCommand)

multiSlotRemoteController.onButtonWasTapped(slotNum: 2)
multiSlotRemoteController.offButtonWasTapped(slotNum: 2)
multiSlotRemoteController.undoButtonWasTapped()
multiSlotRemoteController.onButtonWasTapped(slotNum: 4)
multiSlotRemoteController.undoButtonWasTapped()

///여러 동작을 한번에 처리하기위한 커맨드
class MacroCommand: Command {
    
    let commands: [Command]
    
    init(commands: [Command]) {
        self.commands = commands
    }
    func execute() {
        commands.forEach {
            $0.execute()
        }
    }
    
    func undo() {
        commands.forEach {
            $0.undo()
        }
    }
}

///매크로 커맨드에 커맨드의 배열을 만들어서 전달
let partyOn: [Command] = [lightOnCommand, airConditionerOnCommand, ceilingFanHighCommand]
let partyOff: [Command] = [lightOffCommand, airConditionerOffCommand, ceilingFanOffCommand]

let partyOnMacro: MacroCommand = MacroCommand(commands: partyOn)
let partyOffMacro: MacroCommand = MacroCommand(commands: partyOff)

multiSlotRemoteController.setCommand(slotNum: 5, onCommand: partyOnMacro, offCommand: partyOffMacro)
multiSlotRemoteController.checkSlotState()
multiSlotRemoteController.onButtonWasTapped(slotNum: 5)
multiSlotRemoteController.offButtonWasTapped(slotNum: 5)
multiSlotRemoteController.undoButtonWasTapped()
