; Original code by toralf and Laszlo on Autohotkey.com
; Modified by KR1ZZ1
Levenshtein_distance(s, t) {
    If (s == t)
        return 0
    If (n := StrLen(s)) = 0 || (m := StrLen(t)) = 0
        return Max(m,n)

    d0_0 := 0
    Loop, % n
        d0_%A_Index% := A_Index
    Loop, % m
        d%A_Index%_0 := A_Index

    Loop, Parse, s
    {
        i := A_Index, i1 := i-1, si := A_LoopField
        Loop, Parse, t
            j1 := A_Index - 1, d%A_Index%_%i% := Min(d%A_Index%_%i1%+1, d%j1%_%i%+1, d%j1%_%i1%+(si <> A_LoopField))
    }
    Return d%m%_%n%
    }