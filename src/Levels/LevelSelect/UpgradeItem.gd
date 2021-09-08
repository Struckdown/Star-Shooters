extends MarginContainer


export(String) var upgradeName
var curCost
export(Array, float) var upgradeLevels
export(String) var upgradeLevelSuffix
export(int) var baseCost = 100
var upgradeLevel = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	if upgradeName in UpgradeManager.upgrades:
		upgradeLevel = UpgradeManager.upgrades[upgradeName]["curLevel"]
	else:	# set up data
		UpgradeManager.upgrades[upgradeName] = {
			"curLevel":0,
			"upgradeLevels":upgradeLevels,
			"startingCost": baseCost,
		}
	curCost = getCost(upgradeLevel)
	updateProgressBarVisuals()
	updateNextLevelText()
	$Button/CostLbl.text = "x" + str(getCost(upgradeLevel))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func getCost(level):
	if upgradeLevel >= len(upgradeLevels)-1:
		return "MAX"
	return baseCost*((level+1)*1.5)	#TODO come up with better formula

func updateNextLevelText():	# updates the a->b text
	var levelValues = UpgradeManager.upgrades[upgradeName]["upgradeLevels"]
	if len(levelValues) == 0:
		print("Upgrade Levels not setup for ", upgradeName)
		return
	var curVal = levelValues[upgradeLevel]
	var nextVal = null
	if upgradeLevel+1 >= len(levelValues):
		nextVal = null	# no more levels!
	else:
		nextVal = levelValues[upgradeLevel+1]
	if nextVal:
		$Button/ChangeLbl.text = str(curVal) + upgradeLevelSuffix + "->" + str(nextVal) + upgradeLevelSuffix
	else:
		$Button/ChangeLbl.text = str(curVal) + upgradeLevelSuffix

func updateProgressBarVisuals():
	var cur = float(upgradeLevel)
	var maximum = float(len(UpgradeManager.upgrades[upgradeName]["upgradeLevels"])) - 1
	var upgradePercent =  cur / maximum
	$Button/ProgressBar.updateFraction(upgradePercent)

func _on_Button_button_up():
	var curGems = UpgradeManager.gems
	if str(curCost) == "MAX" or curCost > curGems or (upgradeLevel >= len(upgradeLevels)-1):
		$ErrorSFX.play()
		return
	$UpgradeSFX.play()
	curGems -= curCost
	UpgradeManager.setGems(curGems)
	upgradeLevel += 1
	updateNextLevelText()
	curCost = getCost(upgradeLevel)
	$Button/CostLbl.text = "x" + str(getCost(upgradeLevel))
	updateProgressBarVisuals()
	UpgradeManager.upgrades[upgradeName]["curLevel"] = upgradeLevel
