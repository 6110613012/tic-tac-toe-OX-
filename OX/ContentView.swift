//
//  ContentView.swift
//  OX
//
//  Created by Sunanta Chuathue on 28/8/2564 BE.
//

import SwiftUI

struct ContentView: View {
    @State private var moves: [Move?] = Array(repeating: nil, count: 9)
    @State private var isGameboardDisabled = false
    @State private var alertItem: AlertItem?
    @State private var isHumansTurn = true
    var body: some View {
        NavigationView{
            LazyVGrid(columns: [GridItem(), GridItem(), GridItem()]){
                ForEach(0..<9){ i in
                    ZStack{
                        Color.blue
                            .opacity(0.5)
                            .frame(width: squareSize(), height: squareSize())
                            .cornerRadius(15)
                        Image(systemName: moves[i]?.mark ?? "xmark.circle")
                            .resizable()
                            .frame(width: markeSize(), height: markeSize())
                            .foregroundColor(.white)
                            .opacity(moves[i] == nil ? 0 : 1)
                    }
                    .onTapGesture {
                        if isSquarOccupied(in: moves, forIndex: i) {return}
                        
                        //moves[i] = Move(player: .human , boardIndex: i)
                        
                        moves[i] = Move(player: .human , boardIndex: i)
                        
                        if checkWinCondition(for: .human, in: moves) {
                            isHumansTurn.toggle()
                            alertItem = AlertContext.humanWin
                            return
                        }
                        
                        if checkForDraw(in: moves) {
                            isHumansTurn.toggle()
                            alertItem = AlertContext.draw
                            return
                        }
                        isGameboardDisabled.toggle()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            let computerPosition = determineComputerMove(in: moves)
                            moves[computerPosition] = Move(player: .computer, boardIndex: computerPosition)
                            isGameboardDisabled.toggle()
                            if checkWinCondition(for: .computer, in: moves) {
                                isHumansTurn.toggle()
                                alertItem = AlertContext.computerWin
                            }
                            if checkForDraw(in: moves) {
                                isHumansTurn.toggle()
                                alertItem = AlertContext.draw
                                return
                            }
                        }
                    }
                }
            }
            .padding()
            .disabled(isGameboardDisabled)
            .navigationTitle("OX/XO")
            .alert(item: $alertItem) { alertItem in
                Alert(title: Text(alertItem.title), message: Text(alertItem.message), dismissButton: .default(Text(alertItem.buttonTitle), action: resetGame))
            }
        }
    }
    func resetGame() {
        moves = Array(repeating: nil, count: 9)
        if isHumansTurn != true{
            let computerPosition = whenComputerFirst(in: moves)
            moves[computerPosition] = Move(player: .computer, boardIndex: computerPosition)
        }
    }
    
    func checkWinCondition(for player: Player, in moves: [Move?]) -> Bool {
        let winPatterns: Array<Set<Int>> = [[0, 1, 2], [3, 4, 5], [6, 7, 8], [0, 3, 6], [1, 4, 7], [2, 5, 8], [0, 4, 8], [2, 4, 6]]
        
        //let playerMoves = moves.compactMap { $0 }.filter { $0.player == player }
        //let playerPosition = playerMoves.map { $0.boardIndex }
        let playerPosition = Set(moves.compactMap { $0 }
                                    .filter { $0.player == player }
                                    .map { $0.boardIndex })
        
        for pattern in winPatterns {
            if pattern.isSubset(of: playerPosition){
                return true
            }
        }
        
        return false
        
    }
    
    func checkForDraw(in moves: [Move?]) -> Bool {
        moves.compactMap { $0 }.count == 9
    }
    
    func isSquarOccupied(in moves: [Move?], forIndex index: Int) -> Bool {
        moves[index] != nil
    }
    
    func determineComputerMove(in moves: [Move?]) -> Int {
        let winPatterns: Array<Set<Int>> = [[0, 1, 2], [3, 4, 5], [6, 7, 8], [0, 3, 6], [1, 4, 7], [2, 5, 8], [0, 4, 8], [2, 4, 6]]
        // If AI can win, then wins
        let computerPositions = Set(moves.compactMap { $0 }
                                    .filter { $0.player == .computer }
                                    .map { $0.boardIndex })
        for pattern in winPatterns {
            let winPositions = pattern.subtracting(computerPositions)
            if winPositions.count == 1 {
                if !isSquarOccupied(in: moves, forIndex: winPositions.first!) {
                    return winPositions.first!
                }
            }
        }
        // If AI can't win, then blocks
        let humanPositions = Set(moves.compactMap { $0 }
                                    .filter { $0.player == .human }
                                    .map { $0.boardIndex })
        for pattern in winPatterns {
            let BlockPositions = pattern.subtracting(humanPositions)
            if BlockPositions.count == 1 {
                if !isSquarOccupied(in: moves, forIndex: BlockPositions.first!) {
                    return BlockPositions.first!
                }
            }
        }
        // If AI can't block, then take middle squar
        let middlePosition = 4
        if !isSquarOccupied(in: moves, forIndex: middlePosition) {
            return middlePosition
        }
        
        // If AL can't take middle squar, then take random available squar
        var movePosition = Int.random(in: 0..<9)
        
        while isSquarOccupied(in: moves, forIndex: movePosition){
            movePosition = Int.random(in: 0..<9)
        }
        return movePosition
    }
    
    func whenComputerFirst(in moves: [Move?]) -> Int {
        let winPatterns: Array<Set<Int>> = [[0, 1, 2], [3, 4, 5], [6, 7, 8], [0, 3, 6], [1, 4, 7], [2, 5, 8], [0, 4, 8], [2, 4, 6]]
        var movePosition = Int.random(in: 0..<9)
        
        while isSquarOccupied(in: moves, forIndex: movePosition){
            movePosition = Int.random(in: 0..<9)
        }
        return movePosition
    }
    
    func squareSize() -> CGFloat {
        UIScreen.main.bounds.width / 3 - 15
    }
    
    func markeSize() -> CGFloat {
        squareSize() / 2
    }
    
}

enum Player {
    case human, computer
}

struct Move {
    let player: Player
    let boardIndex: Int
    
    var mark: String{
        player == .human ? "xmark" : "circle"
    }
}

struct AlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let buttonTitle: String
}

struct AlertContext {
    static let humanWin = AlertItem(title: "You Wim!", message: "You are smart", buttonTitle: "Hell Yeah" )
    static let draw = AlertItem(title: "Draw", message: "What a battle", buttonTitle: "Try again" )
    static let computerWin = AlertItem(title: "You Lose!", message: "Better luck next time", buttonTitle: "Rematch" )
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
