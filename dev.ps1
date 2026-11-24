Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Windows.Forms.Application]::EnableVisualStyles()

$form = New-Object System.Windows.Forms.Form
$form.Text = "MELSOFT GXWORKS 4"
$form.Size = New-Object System.Drawing.Size(1280, 780)
$form.StartPosition = "CenterScreen"

$iconPath = "C:\Users\hhn70\Downloads\gxwork4-logo.ico"
if (Test-Path -LiteralPath $iconPath) {
    $form.Icon = New-Object System.Drawing.Icon($iconPath)
}

$script:TargetPlc = "FX3U"

$toolStrip = New-Object System.Windows.Forms.ToolStrip
$toolStrip.Dock = [System.Windows.Forms.DockStyle]::Top
$toolStrip.BackColor = [System.Drawing.Color]::FromArgb(240, 244, 248)
$toolStrip.GripStyle = [System.Windows.Forms.ToolStripGripStyle]::Hidden

$btnTargetPlc = New-Object System.Windows.Forms.ToolStripButton("Target Device")
$sep1         = New-Object System.Windows.Forms.ToolStripSeparator
$btnNO        = New-Object System.Windows.Forms.ToolStripButton("-| |- (NO)")
$btnNC        = New-Object System.Windows.Forms.ToolStripButton("-|/|- (NC)")
$btnCoil      = New-Object System.Windows.Forms.ToolStripButton("-( )- (Coil)")
$btnDel       = New-Object System.Windows.Forms.ToolStripButton("Delete")
$btnAddRung   = New-Object System.Windows.Forms.ToolStripButton("+ Add Rung")
$btnDelRung   = New-Object System.Windows.Forms.ToolStripButton("- Del Rung")
$btnCleanNop  = New-Object System.Windows.Forms.ToolStripButton("Clean NOP")
$sep2         = New-Object System.Windows.Forms.ToolStripSeparator
$btnCompile   = New-Object System.Windows.Forms.ToolStripButton("Compile")
$btnCompile.BackColor = [System.Drawing.Color]::FromArgb(220, 238, 255)

[void]$toolStrip.Items.AddRange(@($btnTargetPlc, $sep1, $btnNO, $btnNC, $btnCoil, $btnDel, $btnAddRung, $btnDelRung, $btnCleanNop, $sep2, $btnCompile))

$split = New-Object System.Windows.Forms.SplitContainer
$split.Dock = [System.Windows.Forms.DockStyle]::Fill
$split.FixedPanel = [System.Windows.Forms.FixedPanel]::Panel1

$tree = New-Object System.Windows.Forms.TreeView
$tree.Dock = [System.Windows.Forms.DockStyle]::Fill
$tree.Font = New-Object System.Drawing.Font("Segoe UI", 10)

$rootNode  = New-Object System.Windows.Forms.TreeNode("PLC Project ($($script:TargetPlc))")
$progNode  = New-Object System.Windows.Forms.TreeNode("Program")
$rungList  = New-Object System.Windows.Forms.TreeNode("Rungs")
$devNode   = New-Object System.Windows.Forms.TreeNode("Devices")
[void]$devNode.Nodes.Add("Inputs (X)")
[void]$devNode.Nodes.Add("Outputs (Y)")
[void]$devNode.Nodes.Add("Internal Relays (M)")

[void]$progNode.Nodes.Add($rungList)
[void]$rootNode.Nodes.Add($progNode)
[void]$rootNode.Nodes.Add($devNode)
[void]$tree.Nodes.Add($rootNode)
$rootNode.Expand()
$progNode.Expand()
$rungList.Expand()

$mainContent = New-Object System.Windows.Forms.Panel
$mainContent.Dock = [System.Windows.Forms.DockStyle]::Fill
$mainContent.BackColor = [System.Drawing.Color]::White

$cmdBar = New-Object System.Windows.Forms.Panel
$cmdBar.Dock = [System.Windows.Forms.DockStyle]::Top
$cmdBar.Height = 40
$cmdBar.BackColor = [System.Drawing.Color]::FromArgb(245, 247, 250)

$lblCmd = New-Object System.Windows.Forms.Label
$lblCmd.Text = "Instruction (LD X0, LDI X1, OUT Y0, NOP):"
$lblCmd.Location = New-Object System.Drawing.Point(10, 11)
$lblCmd.AutoSize = $true
$lblCmd.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)

$txtCmd = New-Object System.Windows.Forms.TextBox
$txtCmd.Location = New-Object System.Drawing.Point(255, 8)
$txtCmd.Size = New-Object System.Drawing.Size(210, 24)
$txtCmd.Font = New-Object System.Drawing.Font("Consolas", 10)

$btnApplyCmd = New-Object System.Windows.Forms.Button
$btnApplyCmd.Text = "Apply"
$btnApplyCmd.Location = New-Object System.Drawing.Point(475, 7)
$btnApplyCmd.Size = New-Object System.Drawing.Size(80, 26)

$cmdBar.Controls.AddRange(@($lblCmd, $txtCmd, $btnApplyCmd))

$outputPanel = New-Object System.Windows.Forms.Panel
$outputPanel.Dock = [System.Windows.Forms.DockStyle]::Bottom
$outputPanel.Height = 135
$outputPanel.BackColor = [System.Drawing.Color]::FromArgb(248, 250, 252)

$lblOut = New-Object System.Windows.Forms.Label
$lblOut.Text = "Compile Output:"
$lblOut.Dock = [System.Windows.Forms.DockStyle]::Top
$lblOut.Height = 22
$lblOut.Padding = New-Object System.Windows.Forms.Padding(8, 4, 0, 0)
$lblOut.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)

$txtOutput = New-Object System.Windows.Forms.TextBox
$txtOutput.Dock = [System.Windows.Forms.DockStyle]::Fill
$txtOutput.Multiline = $true
$txtOutput.ScrollBars = [System.Windows.Forms.ScrollBars]::Both
$txtOutput.ReadOnly = $true
$txtOutput.Font = New-Object System.Drawing.Font("Consolas", 9.5)
$txtOutput.BackColor = [System.Drawing.Color]::White
$txtOutput.Text = "Ready. Click 'Compile' to check syntax and rung structure."

$outputPanel.Controls.Add($txtOutput)
$outputPanel.Controls.Add($lblOut)

$canvas = New-Object System.Windows.Forms.Panel
$canvas.Dock = [System.Windows.Forms.DockStyle]::Fill
$canvas.BackColor = [System.Drawing.Color]::White
$canvas.AutoScroll = $true

$mainContent.Controls.Add($canvas)
$mainContent.Controls.Add($outputPanel)
$mainContent.Controls.Add($cmdBar)

$split.Panel1.Controls.Add($tree)
$split.Panel2.Controls.Add($mainContent)

$script:RungCount = 5
$script:ColCount  = 8
$script:CellW     = 110
$script:CellH     = 90
$script:StartX    = 40
$script:StartY    = 30
$script:SelRung   = 0
$script:SelCol    = 0
$script:Grid      = @{}

# --- ContextMenuStrip cho Canvas (chuot phai len o Ladder) ---
$ctxCanvas = New-Object System.Windows.Forms.ContextMenuStrip
$miInsNO     = New-Object System.Windows.Forms.ToolStripMenuItem("Insert NO (-| |-)")
$miInsNC     = New-Object System.Windows.Forms.ToolStripMenuItem("Insert NC (-|/|-)")
$miInsCoil   = New-Object System.Windows.Forms.ToolStripMenuItem("Insert Coil -( )-")
$miDelCell   = New-Object System.Windows.Forms.ToolStripMenuItem("Delete Cell (NOP)")
$miSepCanvas = New-Object System.Windows.Forms.ToolStripSeparator
$miAddRung   = New-Object System.Windows.Forms.ToolStripMenuItem("Add Rung at End")
$miDelRung   = New-Object System.Windows.Forms.ToolStripMenuItem("Delete Current Rung")
[void]$ctxCanvas.Items.AddRange(@($miInsNO, $miInsNC, $miInsCoil, $miDelCell, $miSepCanvas, $miAddRung, $miDelRung))
$canvas.ContextMenuStrip = $ctxCanvas

# --- ContextMenuStrip cho TreeView (chuot phai len node trong cay) ---
$ctxTree    = New-Object System.Windows.Forms.ContextMenuStrip
$miTreeAdd  = New-Object System.Windows.Forms.ToolStripMenuItem("Add Rung")
$miTreeDel  = New-Object System.Windows.Forms.ToolStripMenuItem("Delete Selected Rung")
$miTreeClr  = New-Object System.Windows.Forms.ToolStripMenuItem("Clean Empty Rungs")
[void]$ctxTree.Items.AddRange(@($miTreeAdd, $miTreeDel, $miTreeClr))
$tree.ContextMenuStrip = $ctxTree

function Update-CanvasScrollSize {
    $canvas.AutoScrollMinSize = New-Object System.Drawing.Size(
        ($script:StartX + $script:ColCount * $script:CellW + 60),
        ($script:StartY + $script:RungCount * $script:CellH + 60)
    )
}

function Rebuild-RungTreeNodes {
    $rungList.Nodes.Clear()
    for ($r = 0; $r -lt $script:RungCount; $r++) {
        $n = New-Object System.Windows.Forms.TreeNode("Rung $r")
        $n.Tag = $r
        [void]$rungList.Nodes.Add($n)
    }
    $rungList.Expand()
}

function Test-RungHasSymbol {
    param([int]$Rung)
    for ($c = 0; $c -lt $script:ColCount; $c++) {
        if ($script:Grid.ContainsKey("$Rung,$c")) { return $true }
    }
    return $false
}

function Remove-RungAt {
    param([int]$TargetRung)
    if ($TargetRung -lt 0 -or $TargetRung -ge $script:RungCount) { return }

    if ($script:RungCount -le 1) {
        for ($c = 0; $c -lt $script:ColCount; $c++) {
            $k = "0,$c"
            if ($script:Grid.ContainsKey($k)) { $script:Grid.Remove($k) }
        }
        $script:SelRung = 0
        $canvas.Invalidate()
        return
    }

    $newGrid = @{}
    foreach ($entry in $script:Grid.GetEnumerator()) {
        $parts = $entry.Key -split ","
        $r = [int]$parts[0]
        $c = [int]$parts[1]

        if ($r -lt $TargetRung) {
            $newGrid["$r,$c"] = $entry.Value
        } elseif ($r -gt $TargetRung) {
            $newR = $r - 1
            $newGrid["$newR,$c"] = $entry.Value
        }
    }

    $script:Grid = $newGrid
    $script:RungCount--
    if ($script:SelRung -ge $script:RungCount) {
        $script:SelRung = $script:RungCount - 1
    }

    Rebuild-RungTreeNodes
    Update-CanvasScrollSize
    $canvas.Invalidate()
}

function Remove-EmptyRungs {
    $keptRungs = New-Object System.Collections.Generic.List[int]
    for ($r = 0; $r -lt $script:RungCount; $r++) {
        if (Test-RungHasSymbol -Rung $r) {
            $keptRungs.Add($r)
        }
    }

    if ($keptRungs.Count -eq 0) {
        $script:Grid.Clear()
        $script:RungCount = 1
        $script:SelRung = 0
    } else {
        $newGrid = @{}
        for ($newIdx = 0; $newIdx -lt $keptRungs.Count; $newIdx++) {
            $oldR = $keptRungs[$newIdx]
            for ($c = 0; $c -lt $script:ColCount; $c++) {
                $oldKey = "$oldR,$c"
                if ($script:Grid.ContainsKey($oldKey)) {
                    $newGrid["$newIdx,$c"] = $script:Grid[$oldKey]
                }
            }
        }
        $script:Grid = $newGrid
        $script:RungCount = $keptRungs.Count
        if ($script:SelRung -ge $script:RungCount) {
            $script:SelRung = $script:RungCount - 1
        }
    }

    Rebuild-RungTreeNodes
    Update-CanvasScrollSize
    $canvas.Invalidate()
}

function Show-TargetDeviceDialog {
    $dlg = New-Object System.Windows.Forms.Form
    $dlg.Text = "Select Target Device"
    $dlg.Size = New-Object System.Drawing.Size(360, 175)
    $dlg.StartPosition = "CenterParent"
    $dlg.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
    $dlg.MaximizeBox = $false
    $dlg.MinimizeBox = $false

    $lblPlc = New-Object System.Windows.Forms.Label
    $lblPlc.Text = "PLC Type:"
    $lblPlc.Location = New-Object System.Drawing.Point(16, 20)
    $lblPlc.Size = New-Object System.Drawing.Size(80, 22)

    $cmbPlc = New-Object System.Windows.Forms.ComboBox
    $cmbPlc.Location = New-Object System.Drawing.Point(100, 17)
    $cmbPlc.Size = New-Object System.Drawing.Size(225, 26)
    $cmbPlc.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    [void]$cmbPlc.Items.AddRange(@("FX3U", "FX5U", "Q Series", "L Series", "R Series"))
    $cmbPlc.SelectedItem = $script:TargetPlc
    if ($null -eq $cmbPlc.SelectedItem) { $cmbPlc.SelectedIndex = 0 }

    $btnOk = New-Object System.Windows.Forms.Button
    $btnOk.Text = "OK"
    $btnOk.Location = New-Object System.Drawing.Point(155, 85)
    $btnOk.Size = New-Object System.Drawing.Size(80, 30)
    $btnOk.DialogResult = [System.Windows.Forms.DialogResult]::OK

    $btnCancel = New-Object System.Windows.Forms.Button
    $btnCancel.Text = "Cancel"
    $btnCancel.Location = New-Object System.Drawing.Point(245, 85)
    $btnCancel.Size = New-Object System.Drawing.Size(80, 30)
    $btnCancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel

    $dlg.AcceptButton = $btnOk
    $dlg.CancelButton = $btnCancel
    $dlg.Controls.AddRange(@($lblPlc, $cmbPlc, $btnOk, $btnCancel))

    if ($dlg.ShowDialog($form) -eq [System.Windows.Forms.DialogResult]::OK) {
        $script:TargetPlc = [string]$cmbPlc.SelectedItem
        $form.Text = "MELSOFT GXWORKS 4 - [$($script:TargetPlc)]"
        $rootNode.Text = "PLC Project ($($script:TargetPlc))"
    }
    $dlg.Dispose()
}

$btnTargetPlc.Add_Click({
    Show-TargetDeviceDialog
})

function Invoke-LadderCompile {
    $errors = New-Object System.Collections.Generic.List[string]
    $warnings = New-Object System.Collections.Generic.List[string]
    $coilMap = @{}
    $coilCol = $script:ColCount - 1

    for ($r = 0; $r -lt $script:RungCount; $r++) {
        $hasContact = $false
        $hasCoil    = $false

        for ($c = 0; $c -lt $script:ColCount; $c++) {
            $key = "$r,$c"
            if (-not $script:Grid.ContainsKey($key)) { continue }

            $sym  = $script:Grid[$key]
            $type = $sym.Type
            $addr = $sym.Addr

            if ($addr -notmatch "^[XYMTD]\d+$") {
                $errors.Add("ERROR [Rung $r, Col $c]: Invalid device address '$addr' (expected X/Y/M/T/D + digits).")
            }

            if ($type -eq "COIL") {
                $hasCoil = $true
                if ($c -ne $coilCol) {
                    $errors.Add("ERROR [Rung $r, Col $c]: Coil '$addr' must be placed on output column $coilCol.")
                }
                if ($coilMap.ContainsKey($addr)) {
                    $warnings.Add("WARNING [Rung $r, Col $c]: Duplicate OUT coil '$addr' (also used at $($coilMap[$addr])).")
                } else {
                    $coilMap[$addr] = "Rung $r, Col $c"
                }
            } else {
                $hasContact = $true
                if ($c -eq $coilCol) {
                    $warnings.Add("WARNING [Rung $r, Col $c]: Contact '$addr' placed on output column $coilCol.")
                }
            }
        }

        if ($hasContact -and (-not $hasCoil)) {
            $errors.Add("ERROR [Rung $r]: Missing output COIL at column $coilCol for rung condition.")
        } elseif ((-not $hasContact) -and $hasCoil) {
            $warnings.Add("WARNING [Rung $r]: Output COIL has no preceding contact condition.")
        } elseif ((-not $hasContact) -and (-not $hasCoil)) {
            $warnings.Add("WARNING [Rung $r]: Empty rung (NOP).")
        }
    }

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("Target: $($script:TargetPlc) | Rungs: $($script:RungCount) | Errors: $($errors.Count) | Warnings: $($warnings.Count)")
    $lines.Add("----------------------------------------------------------------------")

    foreach ($err in $errors) { $lines.Add($err) }
    foreach ($w in $warnings) { $lines.Add($w) }

    if ($errors.Count -eq 0) {
        $lines.Add("Compile succeeded: 0 syntax/rung errors.")
        $txtOutput.ForeColor = [System.Drawing.Color]::DarkGreen
    } else {
        $lines.Add("Compile failed: fix the errors above.")
        $txtOutput.ForeColor = [System.Drawing.Color]::Firebrick
    }

    $txtOutput.Text = ($lines -join [Environment]::NewLine)
}

$btnCompile.Add_Click({
    Invoke-LadderCompile
})

function Set-CellSymbol {
    param([int]$Rung, [int]$Col, [string]$Type, [string]$Addr)
    $key = "$Rung,$Col"
    if ($Type -eq "NONE") {
        if ($script:Grid.ContainsKey($key)) { $script:Grid.Remove($key) }
    } else {
        $script:Grid[$key] = @{ Type = $Type; Addr = $Addr.ToUpper() }
    }
    $canvas.Invalidate()
}

function Apply-Instruction {
    param([string]$RawCmd)
    $parts = ($RawCmd.Trim() -split "\s+") | Where-Object { $_ -ne "" }
    if ($parts.Count -eq 0) { return }

    $op   = $parts[0].ToUpper()
    $addr = if ($parts.Count -ge 2) { $parts[1].ToUpper() } else { "" }

    switch ($op) {
        "LD"  { Set-CellSymbol -Rung $script:SelRung -Col $script:SelCol -Type "NO"   -Addr ($(if ($addr) { $addr } else { "X0" })) }
        "LDI" { Set-CellSymbol -Rung $script:SelRung -Col $script:SelCol -Type "NC"   -Addr ($(if ($addr) { $addr } else { "X1" })) }
        "OUT" { Set-CellSymbol -Rung $script:SelRung -Col ($script:ColCount - 1) -Type "COIL" -Addr ($(if ($addr) { $addr } else { "Y0" })) }
        "NOP" { Set-CellSymbol -Rung $script:SelRung -Col $script:SelCol -Type "NONE" -Addr "" }
        default {
            [System.Windows.Forms.MessageBox]::Show("Ho tro lenh: LD, LDI, OUT, NOP", "Thong bao") | Out-Null
        }
    }
}

$tree.Add_AfterSelect({
    if ($null -ne $tree.SelectedNode -and $null -ne $tree.SelectedNode.Tag) {
        $script:SelRung = [int]$tree.SelectedNode.Tag
        $script:SelCol  = 0
        $canvas.Invalidate()
    }
})

$tree.Add_NodeMouseClick({
    param($sender, $e)
    if ($e.Button -eq [System.Windows.Forms.MouseButtons]::Right) {
        $tree.SelectedNode = $e.Node
        if ($null -ne $e.Node.Tag) {
            $script:SelRung = [int]$e.Node.Tag
            $script:SelCol  = 0
            $canvas.Invalidate()
        }
    }
})

$miTreeAdd.Add_Click({
    $script:RungCount++
    Rebuild-RungTreeNodes
    Update-CanvasScrollSize
    $canvas.Invalidate()
})

$miTreeDel.Add_Click({
    Remove-RungAt -TargetRung $script:SelRung
})

$miTreeClr.Add_Click({
    Remove-EmptyRungs
})

$btnApplyCmd.Add_Click({
    Apply-Instruction -RawCmd $txtCmd.Text
    $txtCmd.SelectAll()
    $txtCmd.Focus()
})

$txtCmd.Add_KeyDown({
    if ($_.KeyCode -eq [System.Windows.Forms.Keys]::Enter) {
        $_.SuppressKeyPress = $true
        Apply-Instruction -RawCmd $txtCmd.Text
        $txtCmd.SelectAll()
    }
})

$btnNO.Add_Click({
    $addr = if ($txtCmd.Text -match "\b([XYMTD]\d+)\b") { $matches[1] } else { "X$($script:SelCol)" }
    Set-CellSymbol -Rung $script:SelRung -Col $script:SelCol -Type "NO" -Addr $addr
})

$btnNC.Add_Click({
    $addr = if ($txtCmd.Text -match "\b([XYMTD]\d+)\b") { $matches[1] } else { "X$($script:SelCol)" }
    Set-CellSymbol -Rung $script:SelRung -Col $script:SelCol -Type "NC" -Addr $addr
})

$btnCoil.Add_Click({
    $addr = if ($txtCmd.Text -match "\b([XYMTD]\d+)\b") { $matches[1] } else { "Y$($script:SelRung)" }
    Set-CellSymbol -Rung $script:SelRung -Col ($script:ColCount - 1) -Type "COIL" -Addr $addr
})

$btnDel.Add_Click({
    Set-CellSymbol -Rung $script:SelRung -Col $script:SelCol -Type "NONE" -Addr ""
})

$btnAddRung.Add_Click({
    $script:RungCount++
    Rebuild-RungTreeNodes
    Update-CanvasScrollSize
    $canvas.Invalidate()
})

$btnDelRung.Add_Click({
    Remove-RungAt -TargetRung $script:SelRung
})

$btnCleanNop.Add_Click({
    Remove-EmptyRungs
})

$miInsNO.Add_Click({
    $addr = if ($txtCmd.Text -match "\b([XYMTD]\d+)\b") { $matches[1] } else { "X$($script:SelCol)" }
    Set-CellSymbol -Rung $script:SelRung -Col $script:SelCol -Type "NO" -Addr $addr
})

$miInsNC.Add_Click({
    $addr = if ($txtCmd.Text -match "\b([XYMTD]\d+)\b") { $matches[1] } else { "X$($script:SelCol)" }
    Set-CellSymbol -Rung $script:SelRung -Col $script:SelCol -Type "NC" -Addr $addr
})

$miInsCoil.Add_Click({
    $addr = if ($txtCmd.Text -match "\b([XYMTD]\d+)\b") { $matches[1] } else { "Y$($script:SelRung)" }
    Set-CellSymbol -Rung $script:SelRung -Col ($script:ColCount - 1) -Type "COIL" -Addr $addr
})

$miDelCell.Add_Click({
    Set-CellSymbol -Rung $script:SelRung -Col $script:SelCol -Type "NONE" -Addr ""
})

$miAddRung.Add_Click({
    $script:RungCount++
    Rebuild-RungTreeNodes
    Update-CanvasScrollSize
    $canvas.Invalidate()
})

$miDelRung.Add_Click({
    Remove-RungAt -TargetRung $script:SelRung
})

function Select-CanvasCellAtPoint {
    param([System.Drawing.Point]$ClientPoint)
    $x = $ClientPoint.X - $canvas.AutoScrollPosition.X
    $y = $ClientPoint.Y - $canvas.AutoScrollPosition.Y

    $col = [math]::Floor(($x - $script:StartX) / $script:CellW)
    $rung = [math]::Floor(($y - $script:StartY) / $script:CellH)

    if ($rung -ge 0 -and $rung -lt $script:RungCount -and $col -ge 0 -and $col -lt $script:ColCount) {
        $script:SelRung = $rung
        $script:SelCol  = $col
        $canvas.Invalidate()
    }
}

$canvas.Add_MouseClick({
    param($sender, $e)
    Select-CanvasCellAtPoint -ClientPoint $e.Location
})

$canvas.Add_MouseDown({
    param($sender, $e)
    if ($e.Button -eq [System.Windows.Forms.MouseButtons]::Right) {
        Select-CanvasCellAtPoint -ClientPoint $e.Location
    }
})

$canvas.Add_Paint({
    param($sender, $e)
    $g = $e.Graphics
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TranslateTransform($canvas.AutoScrollPosition.X, $canvas.AutoScrollPosition.Y)

    $wirePen   = New-Object System.Drawing.Pen([System.Drawing.Color]::Black, 2)
    $busPen    = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(40, 40, 40), 3)
    $gridPen   = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(230, 235, 242), 1)
    $selPen    = New-Object System.Drawing.Pen([System.Drawing.Color]::DodgerBlue, 2)
    $fontAddr  = New-Object System.Drawing.Font("Consolas", 9, [System.Drawing.FontStyle]::Bold)
    $fontRung  = New-Object System.Drawing.Font("Consolas", 8)
    $brushText = [System.Drawing.Brushes]::DarkBlue
    $brushRung = [System.Drawing.Brushes]::Gray

    $totalW = $script:ColCount * $script:CellW
    $totalH = $script:RungCount * $script:CellH

    $g.DrawLine($busPen, $script:StartX, $script:StartY, $script:StartX, $script:StartY + $totalH)
    $rightBusX = $script:StartX + $totalW
    $g.DrawLine($busPen, $rightBusX, $script:StartY, $rightBusX, $script:StartY + $totalH)

    for ($r = 0; $r -lt $script:RungCount; $r++) {
        $rungCenterY = $script:StartY + $r * $script:CellH + ($script:CellH / 2)
        $rungTopY    = $script:StartY + $r * $script:CellH

        $g.DrawString("[$r]", $fontRung, $brushRung, 8, $rungCenterY - 7)
        $g.DrawLine($wirePen, $script:StartX, $rungCenterY, $rightBusX, $rungCenterY)

        for ($c = 0; $c -lt $script:ColCount; $c++) {
            $cellX = $script:StartX + $c * $script:CellW
            $cellCenterX = $cellX + ($script:CellW / 2)

            $g.DrawRectangle($gridPen, $cellX, $rungTopY, $script:CellW, $script:CellH)

            if ($r -eq $script:SelRung -and $c -eq $script:SelCol) {
                $g.DrawRectangle($selPen, $cellX + 2, $rungTopY + 2, $script:CellW - 4, $script:CellH - 4)
            }

            $key = "$r,$c"
            if ($script:Grid.ContainsKey($key)) {
                $sym = $script:Grid[$key]
                $type = $sym.Type
                $addr = $sym.Addr

                $g.FillRectangle([System.Drawing.Brushes]::White, $cellCenterX - 18, $rungCenterY - 14, 36, 28)

                if ($type -eq "NO") {
                    $g.DrawLine($wirePen, $cellX, $rungCenterY, $cellCenterX - 8, $rungCenterY)
                    $g.DrawLine($wirePen, $cellCenterX - 8, $rungCenterY - 12, $cellCenterX - 8, $rungCenterY + 12)
                    $g.DrawLine($wirePen, $cellCenterX + 8, $rungCenterY - 12, $cellCenterX + 8, $rungCenterY + 12)
                    $g.DrawLine($wirePen, $cellCenterX + 8, $rungCenterY, $cellX + $script:CellW, $rungCenterY)
                }
                elseif ($type -eq "NC") {
                    $g.DrawLine($wirePen, $cellX, $rungCenterY, $cellCenterX - 8, $rungCenterY)
                    $g.DrawLine($wirePen, $cellCenterX - 8, $rungCenterY - 12, $cellCenterX - 8, $rungCenterY + 12)
                    $g.DrawLine($wirePen, $cellCenterX + 8, $rungCenterY - 12, $cellCenterX + 8, $rungCenterY + 12)
                    $g.DrawLine($wirePen, $cellCenterX - 12, $rungCenterY + 11, $cellCenterX + 12, $rungCenterY - 11)
                    $g.DrawLine($wirePen, $cellCenterX + 8, $rungCenterY, $cellX + $script:CellW, $rungCenterY)
                }
                elseif ($type -eq "COIL") {
                    $g.DrawLine($wirePen, $cellX, $rungCenterY, $cellCenterX - 12, $rungCenterY)
                    $g.DrawArc($wirePen, $cellCenterX - 16, $rungCenterY - 12, 16, 24, -70, 140)
                    $g.DrawArc($wirePen, $cellCenterX, $rungCenterY - 12, 16, 24, 110, 140)
                    $g.DrawLine($wirePen, $cellCenterX + 12, $rungCenterY, $cellX + $script:CellW, $rungCenterY)
                }

                $g.DrawString($addr, $fontAddr, $brushText, $cellCenterX - 14, $rungCenterY - 30)
            }
        }
    }

    $wirePen.Dispose(); $busPen.Dispose(); $gridPen.Dispose(); $selPen.Dispose()
    $fontAddr.Dispose(); $fontRung.Dispose()
})

Rebuild-RungTreeNodes
Update-CanvasScrollSize

$form.Controls.Add($split)
$form.Controls.Add($toolStrip)

$form.Add_Shown({
    $split.Panel1MinSize = 150
    $split.Panel2MinSize = 150
    $maxSplit = [math]::Max(150, $split.Width - $split.Panel2MinSize)
    $split.SplitterDistance = [math]::Min(200, $maxSplit)
})

[void]$form.ShowDialog()