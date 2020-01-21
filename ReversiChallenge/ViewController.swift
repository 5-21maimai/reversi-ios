import UIKit

class ViewController: UIViewController {
    @IBOutlet private var boardView: BoardView!
    
    @IBOutlet private var messageDiskView: DiskView!
    @IBOutlet private var messageLabel: UILabel!
    @IBOutlet private var messageDiskSizeConstraint: NSLayoutConstraint!
    private var messageDiskSize: CGFloat! // to store the size designated in the storyboard
    
    @IBOutlet private var darkPlayerControl: UISegmentedControl!
    @IBOutlet private var darkCountLabel: UILabel!
    
    @IBOutlet private var lightPlayerControl: UISegmentedControl!
    @IBOutlet private var lightCountLabel: UILabel!
    
    @IBOutlet private var resetButton: UIButton!
    
    private var turn: Disk? = .dark // `nil` if the current game is over
    private var isAnimating: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        boardView.delegate = self
        messageDiskSize = messageDiskSizeConstraint.constant
        
        newGame()
    }
}

// MARK: Reversi logics

extension ViewController {
    func count(of disk: Disk) -> Int {
        var count = 0
        
        for y in boardView.yRange {
            for x in boardView.xRange {
                if boardView.diskAt(x: x, y: y) == disk {
                    count +=  1
                }
            }
        }
        
        return count
    }
    
    func flippedDiskCoordinatesByPlacingDisk(_ disk: Disk, atX x: Int, y: Int) -> [(Int, Int)] {
        let directions = [
            (x: -1, y: -1),
            (x:  0, y: -1),
            (x:  1, y: -1),
            (x:  1, y:  0),
            (x:  1, y:  1),
            (x:  0, y:  1),
            (x: -1, y:  0),
            (x: -1, y:  1),
        ]
        
        guard boardView.diskAt(x: x, y: y) == nil else {
            return []
        }
        
        var diskCoordinates: [(Int, Int)] = []
        
        for direction in directions {
            var x = x
            var y = y
            
            var diskCoordinatesInLine: [(Int, Int)] = []
            flipping: while true {
                x += direction.x
                y += direction.y
                
                switch (disk, boardView.diskAt(x: x, y: y)) { // Uses tuples to make patterns exhaustive
                case (.dark, .some(.dark)), (.light, .some(.light)):
                    diskCoordinates.append(contentsOf: diskCoordinatesInLine)
                    break flipping
                case (.dark, .some(.light)), (.light, .some(.dark)):
                    diskCoordinatesInLine.append((x, y))
                case (_, .none):
                    break flipping
                }
            }
        }
        
        return diskCoordinates
    }
    
    func canPlaceDisk(_ disk: Disk, atX x: Int, y: Int) -> Bool {
        !flippedDiskCoordinatesByPlacingDisk(disk, atX: x, y: y).isEmpty
    }
    
    func coordinatesToPlaceDisk(_ disk: Disk) -> [(x: Int, y: Int)] {
        var coordinates: [(Int, Int)] = []
        
        for y in boardView.yRange {
            for x in boardView.xRange {
                if canPlaceDisk(disk, atX: x, y: y) {
                    coordinates.append((x, y))
                }
            }
        }
        
        return coordinates
    }

    /// - Parameter completion: A closure to be executed when the animation sequence ends.
    ///     This closure has no return value and takes a single Boolean argument that indicates
    ///     whether or not the animations actually finished before the completion handler was called.
    ///     If `animated` is `false`,  this closure is performed at the beginning of the next run loop cycle. This parameter may be `nil`.
    /// - Throws: `DiskPlacementError` if the `disk` cannot be placed at (`x`, `y`).
    func placeDisk(_ disk: Disk, atX x: Int, y: Int, animated isAnimated: Bool, completion: ((Bool) -> Void)? = nil) throws {
        let diskCoordinates = flippedDiskCoordinatesByPlacingDisk(disk, atX: x, y: y)
        if diskCoordinates.isEmpty {
            throw DiskPlacementError(disk: disk, x: x, y: y)
        }
        
        if isAnimated {
            isAnimating = true
            updateResetButton()
            animateSettingDisks(at: [(x, y)] + diskCoordinates, to: disk) { [weak self] finished in
                guard let self = self else { return }
                completion?(finished)
                self.isAnimating = false
                self.updateResetButton()
                self.updateCountLabels()
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.boardView.setDisk(disk, atX: x, y: y, animated: false)
                for (x, y) in diskCoordinates {
                    self.boardView.setDisk(disk, atX: x, y: y, animated: false)
                }
                completion?(true)
                self.updateCountLabels()
            }
        }
    }
    
    private func animateSettingDisks<C: Collection>(at coordinates: C, to disk: Disk, completion: @escaping (Bool) -> Void)
        where C.Element == (Int, Int)
    {
        guard let (x, y) = coordinates.first else {
            completion(true)
            return
        }
        
        boardView.setDisk(disk, atX: x, y: y, animated: true) { [weak self] finished in
            guard let self = self else { return }
            if finished {
                self.animateSettingDisks(at: coordinates.dropFirst(), to: disk, completion: completion)
            } else {
                for (x, y) in coordinates {
                    self.boardView.setDisk(disk, atX: x, y: y, animated: false)
                }
                completion(false)
            }
        }
    }
}

// MARK: Game management

extension ViewController {
    func newGame() {
        boardView.reset()
        turn = .dark
        
        updateMessageViews()
        updateCountLabels()

        if case .computer = Player(rawValue: darkPlayerControl.selectedSegmentIndex)! {
            playTurnOfComputer()
        }
    }
    
    func nextTurn() {
        guard var turn = self.turn else { return }

        turn.flip()
        
        if coordinatesToPlaceDisk(turn).isEmpty {
            if coordinatesToPlaceDisk(turn.flipped).isEmpty {
                self.turn = nil
                updateMessageViews()
            } else {
                self.turn = turn
                updateMessageViews()
                
                let alertController = UIAlertController(
                    title: "Pass",
                    message: "Cannot place a disk.",
                    preferredStyle: .alert
                )
                alertController.addAction(UIAlertAction(title: "Dismiss", style: .default) { [weak self] _ in
                    self?.nextTurn()
                })
                present(alertController, animated: true)
            }
        } else {
            self.turn = turn
            updateMessageViews()
            
            let playerControl: UISegmentedControl
            switch turn {
            case .dark:
                playerControl = darkPlayerControl
            case .light:
                playerControl = lightPlayerControl
            }
            
            switch Player(rawValue: playerControl.selectedSegmentIndex)! {
            case .manual:
                break
            case .computer:
                DispatchQueue.main.async { [weak self] in
                    self?.playTurnOfComputer()
                }
            }
        }
    }
    
    func winner() -> Disk? {
        let darkCount = count(of: .dark)
        let lightCount = count(of: .light)
        if darkCount == lightCount {
            return nil
        } else {
            return darkCount > lightCount ? .dark : .light
        }
    }
    
    func playTurnOfComputer() {
        guard let turn = self.turn else { preconditionFailure() }
        let (x, y) = coordinatesToPlaceDisk(turn).randomElement()!
        try! placeDisk(turn, atX: x, y: y, animated: true) { [weak self] _ in
            self?.nextTurn()
        }
    }
}

// MARK: Views

extension ViewController {
    func updateCountLabels() {
        darkCountLabel.text = "\(count(of: .dark))"
        lightCountLabel.text = "\(count(of: .light))"
    }
    
    func updateMessageViews() {
        switch turn {
        case .some(let side):
            messageDiskSizeConstraint.constant = messageDiskSize
            messageDiskView.disk = side
            messageLabel.text = "'s turn"
        case .none:
            if let winner = self.winner() {
                messageDiskSizeConstraint.constant = messageDiskSize
                messageDiskView.disk = winner
                messageLabel.text = " won"
            } else {
                messageDiskSizeConstraint.constant = 0
                messageLabel.text = "Draw"
            }
        }
    }
    
    func updateResetButton() {
        if isAnimating {
            resetButton.isEnabled = false
            return
        }
        
        guard let turn = turn else {
            resetButton.isEnabled = true
            return
        }
        
        switch Player(rawValue: playerControl(of: turn).selectedSegmentIndex)! {
        case .manual:
            resetButton.isEnabled = true
        case .computer:
            resetButton.isEnabled = false
        }
    }
    
    func playerControl(of side: Disk) -> UISegmentedControl {
        switch side {
        case .dark: return darkPlayerControl
        case .light: return lightPlayerControl
        }
    }
    
    func side(of playerControl: UISegmentedControl) -> Disk {
        if playerControl === darkPlayerControl {
            return .dark
        } else if playerControl === lightPlayerControl {
            return .light
        } else {
            preconditionFailure()
        }
    }
}

// MARK: Interactions

extension ViewController {
    @IBAction func pressResetButton(_ sender: UIButton) {
        let alertController = UIAlertController(
            title: "Confirmation",
            message: "Do you really want to reset the game?",
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in })
        alertController.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.newGame()
        })
        present(alertController, animated: true)
    }
    
    @IBAction func changePlayerControlSegment(_ sender: UISegmentedControl) {
        let side = self.side(of: sender)
        updateResetButton()
        if !isAnimating, side == turn, case .computer = Player(rawValue: sender.selectedSegmentIndex)! {
            playTurnOfComputer()
        }
    }
}

extension ViewController: BoardViewDelegate {
    func boardView(_ boardView: BoardView, didSelectCellAtX x: Int, y: Int) {
        guard let turn = turn else { return }
        let playerControl = self.playerControl(of: turn)
        if isAnimating { return }
        guard case .manual = Player(rawValue: playerControl.selectedSegmentIndex)! else { return }
        do {
            try placeDisk(turn, atX: x, y: y, animated: true) { [weak self] _ in
                self?.nextTurn()
            }
        } catch _ {
            // Do nothing
        }
    }
}

// MARK: Additional types

extension ViewController {
    enum Player: Int {
        case manual = 0
        case computer = 1
    }
}

struct DiskPlacementError: Error {
    let disk: Disk
    let x: Int
    let y: Int
}
