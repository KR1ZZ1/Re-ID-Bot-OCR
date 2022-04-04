#Include <Levenshtein_distance>
FindString(s, ByRef string := "", ByRef cm := "", Tolerance := 60) {
    Static array := ["Accuracy", "Evasion", "Heal Effect", "Healing Effect", "Crit Heal Chance", "Crit Damage", "Critical Damage", "Crit Defense", "Crit Chance", "Crit Dodge", "Attack", "Defense", "Health", "Mana", "Block Rate", "Block Strength", "Physical Mastery", "Physical Resistance", "Physical Attack", "Physical Defense", "Earth Mastery", "Earth Resistance", "Earth Attack", "Earth Defense", "Water Mastery", "Water Resistance", "Water Attack", "Water Defense", "Fire Mastery", "Fire Resistance", "Fire Attack", "Fire Defense", "Wind Mastery", "Wind Resistance", "Wind Attack", "Wind Defense", "Light Mastery", "Light Resistance", "Light Attack", "Light Defense", "Dark Mastery", "Dark Resistance", "Dark Attack", "Dark Defense"]
    tolp := Round((StrLen(s) / 100) * Tolerance)

    Found := 99999
    For _, c in array
    {
        d := levenshtein_distance(s, c) ; Get distance
        If ((cm := Min(Found, d)) >= Found) ; Get lower distance
            Continue ; If higher distance
        Found := cm, string := c
        If (cm < 2) ; Matching with 1 or less modifications.
            Break
    }

    if (Found >= tolp)
        return -1
    return string
    }