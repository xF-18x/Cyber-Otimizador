@echo off
title Otimizador do Sistema
:: =====================================================================
::  OTIMIZADOR DO SISTEMA  -  by F-18
::  Ficheiro unico, portatil, sem instalar. Consola oculta + GUI WPF.
:: =====================================================================

if /I "%~1"=="/hidden" goto :run

net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -NoProfile -WindowStyle Hidden -Command "Start-Process -FilePath '%~f0' -ArgumentList '/hidden' -Verb RunAs -WindowStyle Hidden"
    exit /b
) else (
    powershell -NoProfile -WindowStyle Hidden -Command "Start-Process -FilePath '%~f0' -ArgumentList '/hidden' -WindowStyle Hidden"
    exit /b
)

:run
set "OTIM_DIR=%~dp0"
set "OTIM_SELF=%~f0"
powershell -NoProfile -ExecutionPolicy Bypass -STA -WindowStyle Hidden -Command "$c=Get-Content -Raw -LiteralPath '%~f0'; $m=('#PSPAYLOAD'+'START'); $i=$c.IndexOf($m); if($i -ge 0){ Invoke-Expression $c.Substring($i + $m.Length) }"
exit /b

#PSPAYLOADSTART
# ====================================================================
#  Otimizador do Sistema - GUI (WPF)  -  by F-18
# ====================================================================
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase
try{ Add-Type -Namespace Native -Name Proc -MemberDefinition @"
[System.Runtime.InteropServices.DllImport("ntdll.dll")] public static extern int NtSuspendProcess(System.IntPtr h);
[System.Runtime.InteropServices.DllImport("ntdll.dll")] public static extern int NtResumeProcess(System.IntPtr h);
"@ }catch{}

function Flush {
    $f = New-Object System.Windows.Threading.DispatcherFrame
    $null = [System.Windows.Threading.Dispatcher]::CurrentDispatcher.BeginInvoke([System.Windows.Threading.DispatcherPriority]::Background, [action]{ $f.Continue = $false })
    [System.Windows.Threading.Dispatcher]::PushFrame($f)
}

# ---------------- JANELA DE ARRANQUE (splash) ----------------
[xml]$splashXaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        WindowStyle="None" AllowsTransparency="True" Background="Transparent" Width="470" Height="250"
        WindowStartupLocation="CenterScreen" ShowInTaskbar="False" Topmost="True" FontFamily="Segoe UI">
  <Border CornerRadius="16" BorderBrush="#FF16324C" BorderThickness="1">
    <Border.Effect><DropShadowEffect Color="#FF000000" BlurRadius="30" ShadowDepth="0" Opacity="0.85"/></Border.Effect>
    <Border.Background>
      <LinearGradientBrush StartPoint="0,0" EndPoint="1,1">
        <GradientStop Color="#FF0A0E17" Offset="0"/><GradientStop Color="#FF0E1A2C" Offset="1"/>
      </LinearGradientBrush>
    </Border.Background>
    <Grid Margin="32,26">
      <TextBlock Text="by F-18" FontFamily="Segoe Script" FontStyle="Italic" FontWeight="Bold" FontSize="82" Foreground="#FFD40000" Opacity="0.08" HorizontalAlignment="Right" VerticalAlignment="Bottom" IsHitTestVisible="False"/>
      <StackPanel VerticalAlignment="Center">
        <TextBlock Text="OTIMIZADOR" FontSize="31" FontWeight="Bold" Foreground="#FF00E5FF">
          <TextBlock.Effect><DropShadowEffect Color="#FF00E5FF" BlurRadius="20" ShadowDepth="0"/></TextBlock.Effect>
        </TextBlock>
        <TextBlock Text="D O   S I S T E M A" FontSize="12" Foreground="#FF5A7A92" Margin="2,0,0,4"/>
        <TextBlock Text="by F-18" FontFamily="Segoe Script" FontStyle="Italic" FontWeight="Bold" FontSize="16" Foreground="#FFD40000" Opacity="0.85" Margin="2,0,0,16">
          <TextBlock.Effect><DropShadowEffect Color="#FFFF1A1A" BlurRadius="8" ShadowDepth="0"/></TextBlock.Effect>
        </TextBlock>
        <ProgressBar x:Name="SBar" Height="6" Minimum="0" Maximum="100" Value="0" Background="#FF0B1220" Foreground="#FF00E5FF" BorderThickness="0">
          <ProgressBar.Effect><DropShadowEffect Color="#FF00E5FF" BlurRadius="12" ShadowDepth="0"/></ProgressBar.Effect>
        </ProgressBar>
        <Grid Margin="0,9,0,0">
          <TextBlock x:Name="STxt" Text="A iniciar..." FontSize="11.5" Foreground="#FF7FB2C8" HorizontalAlignment="Left"/>
          <TextBlock x:Name="SPct" Text="0%" FontSize="11.5" FontWeight="Bold" Foreground="#FF00E5FF" HorizontalAlignment="Right"/>
        </Grid>
      </StackPanel>
    </Grid>
  </Border>
</Window>
"@
$splash=[Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $splashXaml))
$SBar=$splash.FindName('SBar'); $STxt=$splash.FindName('STxt'); $SPct=$splash.FindName('SPct')
function Set-Splash([int]$v,[string]$t){ $SBar.Value=$v; $SPct.Text=("{0}%" -f $v); if($t){ $STxt.Text=$t }; Flush }
$splash.Show()
Set-Splash 6 'A iniciar sistema...'
for($sv=6;$sv -le 30;$sv+=2){ Set-Splash $sv $null; Start-Sleep -Milliseconds 15 }

try {
Set-Splash 36 'A montar interface...'


[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Otimizador do Sistema" Height="700" Width="960"
        WindowStartupLocation="CenterScreen" WindowStyle="None"
        AllowsTransparency="True" Background="Transparent"
        FontFamily="Segoe UI" ResizeMode="CanMinimize">
  <Window.Resources>
    <Style x:Key="WinBtn" TargetType="Button">
      <Setter Property="Background" Value="Transparent"/>
      <Setter Property="Foreground" Value="#FF9FB6C8"/>
      <Setter Property="FontWeight" Value="Bold"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border x:Name="bg" Background="{TemplateBinding Background}" CornerRadius="6">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="bg" Property="Background" Value="#3AFFFFFF"/>
                <Setter Property="Foreground" Value="#FFFFFFFF"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>
    <Style x:Key="WinClose" TargetType="Button">
      <Setter Property="Background" Value="Transparent"/>
      <Setter Property="Foreground" Value="#FFFF6B6B"/>
      <Setter Property="FontWeight" Value="Bold"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border x:Name="bg" Background="{TemplateBinding Background}" CornerRadius="6">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="bg" Property="Background" Value="#FFD40000"/>
                <Setter Property="Foreground" Value="#FFFFFFFF"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>
    <Style x:Key="Nitro" TargetType="Button">
      <Setter Property="Foreground" Value="#FFFFFFFF"/>
      <Setter Property="FontWeight" Value="Bold"/>
      <Setter Property="FontSize" Value="13"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Background">
        <Setter.Value>
          <LinearGradientBrush StartPoint="0,0" EndPoint="1,1">
            <GradientStop Color="#FFFF3B00" Offset="0"/><GradientStop Color="#FFD40000" Offset="1"/>
          </LinearGradientBrush>
        </Setter.Value>
      </Setter>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border x:Name="nb" Background="{TemplateBinding Background}" CornerRadius="7" BorderBrush="#FFFF6A2B" BorderThickness="1.4">
              <Border.Effect><DropShadowEffect x:Name="ng" Color="#FFFF4500" BlurRadius="14" ShadowDepth="0"/></Border.Effect>
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True"><Setter TargetName="nb" Property="BorderBrush" Value="#FFFFC08A"/></Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>
    <Style TargetType="Button">
      <Setter Property="Foreground" Value="#FF00E5FF"/>
      <Setter Property="Background" Value="#FF0E1C2E"/>
      <Setter Property="BorderBrush" Value="#FF00E5FF"/>
      <Setter Property="BorderThickness" Value="1.4"/>
      <Setter Property="FontSize" Value="13.5"/>
      <Setter Property="FontWeight" Value="Bold"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="7">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
      <Style.Triggers>
        <Trigger Property="IsMouseOver" Value="True">
          <Setter Property="Background" Value="#FF17334F"/>
          <Setter Property="Foreground" Value="#FFFFFFFF"/>
        </Trigger>
        <Trigger Property="IsEnabled" Value="False">
          <Setter Property="Foreground" Value="#FF3A4658"/>
          <Setter Property="BorderBrush" Value="#FF223247"/>
        </Trigger>
      </Style.Triggers>
    </Style>
  </Window.Resources>

  <Border CornerRadius="12" BorderBrush="#FF16324C" BorderThickness="1" Margin="10">
    <Border.Effect><DropShadowEffect Color="#FF000000" BlurRadius="24" ShadowDepth="0" Opacity="0.8"/></Border.Effect>
    <Border.Background>
      <LinearGradientBrush StartPoint="0,0" EndPoint="0,1">
        <GradientStop Color="#FF0A0E17" Offset="0"/><GradientStop Color="#FF0E1626" Offset="1"/>
      </LinearGradientBrush>
    </Border.Background>

    <Grid>
      <TextBlock Text="by F-18" FontFamily="Segoe Script" FontStyle="Italic" FontWeight="Bold"
                 FontSize="150" Foreground="#FFD40000" Opacity="0.10"
                 HorizontalAlignment="Right" VerticalAlignment="Bottom" Margin="0,0,20,60" IsHitTestVisible="False"/>

      <Grid>
        <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/></Grid.RowDefinitions>

        <!-- Barra de titulo -->
        <Grid x:Name="TitleBar" Grid.Row="0" Height="46" Background="#01000000">
          <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
          <TextBlock Grid.Column="0" Text="OTIMIZADOR DO SISTEMA" FontSize="25" FontWeight="Bold" Foreground="#FF00E5FF" VerticalAlignment="Center" Margin="18,0,0,0">
            <TextBlock.Effect><DropShadowEffect Color="#FF00E5FF" BlurRadius="16" ShadowDepth="0"/></TextBlock.Effect>
          </TextBlock>
          <TextBlock Grid.Column="1" Text="by F-18" FontFamily="Segoe Script" FontStyle="Italic" FontWeight="Bold" FontSize="17" Foreground="#FFD40000" Opacity="0.5" VerticalAlignment="Center" Margin="0,0,14,0" IsHitTestVisible="False">
            <TextBlock.Effect><DropShadowEffect Color="#FFFF1A1A" BlurRadius="8" ShadowDepth="0"/></TextBlock.Effect>
          </TextBlock>
          <StackPanel Grid.Column="2" Orientation="Horizontal" VerticalAlignment="Top" Margin="0,4,8,0">
            <Button x:Name="Min" Content="&#x2013;" Width="44" Height="34" FontSize="15" Style="{DynamicResource WinBtn}"/>
            <Button x:Name="Max" Content="&#x25A1;" Width="44" Height="34" FontSize="13" Style="{DynamicResource WinBtn}"/>
            <Button x:Name="Exit" Content="&#x2715;" Width="44" Height="34" FontSize="14" Style="{DynamicResource WinClose}"/>
          </StackPanel>
        </Grid>

        <!-- Corpo: conteudo + painel de sensores -->
        <Grid Grid.Row="1">
          <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="188"/></Grid.ColumnDefinitions>

          <!-- Coluna principal -->
          <Grid Grid.Column="0">
            <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>

            <TextBlock Grid.Row="0" Text="LIMPEZA  //  BLOATWARE  //  TELEMETRIA  //  REPARACAO  //  DISCO" FontSize="11" Foreground="#FFFF2D95" Margin="20,0,0,8"/>

            <Border Grid.Row="1" Margin="16,0,10,8" CornerRadius="10" Background="#FF0B1524" BorderBrush="#FF16324C" BorderThickness="1">
              <Grid>
                <ScrollViewer x:Name="Scroller" VerticalScrollBarVisibility="Auto" Padding="14">
                  <StackPanel x:Name="StepPanel"/>
                </ScrollViewer>
                <Border x:Name="Summary" Visibility="Collapsed" CornerRadius="10" Background="#FA0B1524">
                  <StackPanel VerticalAlignment="Center" HorizontalAlignment="Center">
                    <TextBlock x:Name="SumTitle" Text="CONCLUIDO" FontSize="15" FontWeight="Bold" Foreground="#FF39FF9E" HorizontalAlignment="Center" Margin="0,0,0,6">
                      <TextBlock.Effect><DropShadowEffect Color="#FF39FF9E" BlurRadius="16" ShadowDepth="0"/></TextBlock.Effect>
                    </TextBlock>
                    <TextBlock x:Name="FreedBig" Text="0 MB" FontSize="56" FontWeight="Bold" Foreground="#FF00E5FF" HorizontalAlignment="Center">
                      <TextBlock.Effect><DropShadowEffect Color="#FF00E5FF" BlurRadius="22" ShadowDepth="0"/></TextBlock.Effect>
                    </TextBlock>
                    <TextBlock x:Name="FreedSub" Text="espaco libertado" FontSize="13" Foreground="#FF7FB2C8" HorizontalAlignment="Center" Margin="0,0,0,18"/>
                    <StackPanel Orientation="Horizontal" HorizontalAlignment="Center">
                      <Border CornerRadius="8" Background="#FF0E1C2E" Padding="18,10" Margin="6,0"><StackPanel><TextBlock x:Name="OkCount" Text="0" FontSize="24" FontWeight="Bold" Foreground="#FF39FF9E" HorizontalAlignment="Center"/><TextBlock Text="concluidos" FontSize="11" Foreground="#FF7FB2C8" HorizontalAlignment="Center"/></StackPanel></Border>
                      <Border CornerRadius="8" Background="#FF0E1C2E" Padding="18,10" Margin="6,0"><StackPanel><TextBlock x:Name="FailCount" Text="0" FontSize="24" FontWeight="Bold" Foreground="#FFFF6B6B" HorizontalAlignment="Center"/><TextBlock Text="falharam" FontSize="11" Foreground="#FF7FB2C8" HorizontalAlignment="Center"/></StackPanel></Border>
                      <Border CornerRadius="8" Background="#FF0E1C2E" Padding="18,10" Margin="6,0"><StackPanel><TextBlock x:Name="TimeVal" Text="00:00" FontSize="24" FontWeight="Bold" Foreground="#FFFFC24B" HorizontalAlignment="Center"/><TextBlock Text="tempo" FontSize="11" Foreground="#FF7FB2C8" HorizontalAlignment="Center"/></StackPanel></Border>
                    </StackPanel>
                    <TextBlock Text="Reinicia o PC para aplicar tudo." FontSize="12" Foreground="#FFFFC24B" HorizontalAlignment="Center" Margin="0,18,0,14"/>
                    <StackPanel Orientation="Horizontal" HorizontalAlignment="Center">
                      <Button x:Name="SeeList" Content="VER DETALHES" Width="150" Height="40" Margin="6,0"/>
                      <Button x:Name="SumExit" Content="SAIR" Width="120" Height="40" Margin="6,0"/>
                    </StackPanel>
                  </StackPanel>
                </Border>
              </Grid>
            </Border>

            <Grid Grid.Row="2" Margin="18,0,10,8">
              <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
              <TextBlock x:Name="Working" Grid.Row="0" Visibility="Collapsed" Text="A PROCESSAR - NAO FECHE A JANELA" FontWeight="Bold" FontSize="12.5" Foreground="#FF00E5FF" Margin="2,0,0,5">
                <TextBlock.Effect><DropShadowEffect Color="#FF00E5FF" BlurRadius="14" ShadowDepth="0"/></TextBlock.Effect>
              </TextBlock>
              <TextBlock x:Name="Status" Grid.Row="1" Text="Seleciona um modo:" Foreground="#FFF2FFFF" FontWeight="Bold" FontSize="14.5" Margin="2,0,0,5">
                <TextBlock.Effect><DropShadowEffect Color="#FF9BF6FF" BlurRadius="4" ShadowDepth="0" Opacity="0.5"/></TextBlock.Effect>
              </TextBlock>
              <ProgressBar x:Name="Bar" Grid.Row="2" Height="18" Minimum="0" Maximum="100" Value="0" Background="#FF0B1220" Foreground="#FF00E5FF" BorderBrush="#FF16324C" BorderThickness="1">
                <ProgressBar.Effect><DropShadowEffect Color="#FF00E5FF" BlurRadius="10" ShadowDepth="0"/></ProgressBar.Effect>
              </ProgressBar>
            </Grid>

            <StackPanel Grid.Row="3" Margin="16,4,6,14">
              <UniformGrid Rows="1" Columns="4" Margin="0,0,0,8">
                <Button x:Name="CloseApps" Content="FECHAR APPS" Height="44" Margin="4,0" FontSize="12"/>
                <Button x:Name="Proc" Content="PROCESSOS" Height="44" Margin="4,0" FontSize="12"/>
                <Button x:Name="Lat" Content="LATENCIA" Height="44" Margin="4,0" FontSize="12"/>
                <Button x:Name="Tools" Content="FERRAMENTAS" Height="44" Margin="4,0" FontSize="11.5"/>
              </UniformGrid>
              <UniformGrid Rows="1" Columns="3">
                <Button x:Name="Nitro" Content="&#x26A1; NITRO" Height="46" Margin="4,0" Style="{DynamicResource Nitro}"/>
                <Button x:Name="Quick" Content="MODO RAPIDO" Height="46" Margin="4,0"/>
                <Button x:Name="Deep" Content="MODO PROFUNDO" Height="46" Margin="4,0"/>
              </UniformGrid>
            </StackPanel>
          </Grid>

          <!-- Painel de temperaturas -->
          <Border Grid.Column="1" Margin="0,0,10,10" CornerRadius="10" Background="#FF0A1220" BorderBrush="#FF16324C" BorderThickness="1">
            <ScrollViewer VerticalScrollBarVisibility="Auto">
              <StackPanel Margin="10,10">
                <TextBlock Text="TEMPERATURAS" FontSize="12" FontWeight="Bold" Foreground="#FF00E5FF" HorizontalAlignment="Center" Margin="0,0,0,10">
                  <TextBlock.Effect><DropShadowEffect Color="#FF00E5FF" BlurRadius="10" ShadowDepth="0"/></TextBlock.Effect>
                </TextBlock>
                <StackPanel x:Name="TempPanel"/>
                <TextBlock Text="SISTEMA" FontSize="12" FontWeight="Bold" Foreground="#FF00E5FF" HorizontalAlignment="Center" Margin="0,8,0,8"><TextBlock.Effect><DropShadowEffect Color="#FF00E5FF" BlurRadius="10" ShadowDepth="0"/></TextBlock.Effect></TextBlock>
                <StackPanel x:Name="SysPanel"/>
                <Border Height="1" Background="#FF16324C" Margin="4,2,4,8"/>
                <TextBlock x:Name="SrcTxt" Text="Fonte: --" FontSize="10.5" Foreground="#FF5A6B80" HorizontalAlignment="Center" TextWrapping="Wrap" TextAlignment="Center"/>
                <TextBlock x:Name="VerTxt" Text="" FontSize="10" Foreground="#FF44566B" HorizontalAlignment="Center" Margin="0,3,0,0"/>
              </StackPanel>
            </ScrollViewer>
          </Border>
        </Grid>
      </Grid>
    </Grid>
  </Border>
</Window>
"@

$win = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $xaml))
$c = { param($n) $win.FindName($n) }
$TitleBar=&$c 'TitleBar'; $Min=&$c 'Min'; $Max=&$c 'Max'; $Exit=&$c 'Exit'
$StepPanel=&$c 'StepPanel'; $Scroller=&$c 'Scroller'; $Summary=&$c 'Summary'; $SumTitle=&$c 'SumTitle'
$Working=&$c 'Working'; $Status=&$c 'Status'; $Bar=&$c 'Bar'
$CloseApps=&$c 'CloseApps'; $Proc=&$c 'Proc'; $Lat=&$c 'Lat'; $Nitro=&$c 'Nitro'; $Quick=&$c 'Quick'; $Deep=&$c 'Deep'; $Tools=&$c 'Tools'; $SysPanel=&$c 'SysPanel'; $VerTxt=&$c 'VerTxt'
$FreedBig=&$c 'FreedBig'; $FreedSub=&$c 'FreedSub'; $OkCount=&$c 'OkCount'; $FailCount=&$c 'FailCount'; $TimeVal=&$c 'TimeVal'
$SeeList=&$c 'SeeList'; $SumExit=&$c 'SumExit'
$TempPanel=&$c 'TempPanel'; $SrcTxt=&$c 'SrcTxt'

$bc = { param($h) (New-Object System.Windows.Media.BrushConverter).ConvertFromString($h) }
$cCyan=&$bc '#FF00E5FF'; $cGreen=&$bc '#FF39FF9E'; $cRed=&$bc '#FFFF6B6B'
$cAmber=&$bc '#FFFFC24B'; $cMuted=&$bc '#FF7FB2C8'; $cFaint=&$bc '#FF5A6B80'; $cText=&$bc '#FFF2FFFF'
$cCard=&$bc '#FF12233A'

$TitleBar.Add_MouseLeftButtonDown({ if ($_.ButtonState -eq 'Pressed') { $win.DragMove() } })
$Min.Add_Click({ $win.WindowState = 'Minimized' })
$Max.Add_Click({ if ($win.WindowState -eq 'Normal') { $win.MaxHeight=[System.Windows.SystemParameters]::WorkArea.Height; $win.MaxWidth=[System.Windows.SystemParameters]::WorkArea.Width; $win.WindowState='Maximized' } else { $win.WindowState='Normal' } })
$Exit.Add_Click({ $win.Close() })
$SumExit.Add_Click({ $win.Close() })
$SeeList.Add_Click({ $Summary.Visibility='Collapsed' })

function Clear-Folder([string]$p){ if(Test-Path -LiteralPath $p){ Get-ChildItem -LiteralPath $p -Force -EA SilentlyContinue | Remove-Item -Recurse -Force -EA SilentlyContinue } }
function FreeBytes { (Get-PSDrive C).Free }
function Wait-Proc($proc,[string]$label){ $Bar.IsIndeterminate=$true; $i=0; while(-not $proc.HasExited){ $Status.Text="$label a processar$('.'*(($i%4)+1)) (pode demorar - aguarde)"; Flush; Start-Sleep -Milliseconds 400; $i++ }; $Bar.IsIndeterminate=$false }

$rowXaml = @"
<Border xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Background="#FF0E1C2E" CornerRadius="7" Padding="11,8" Margin="0,0,0,7">
  <Grid>
    <Grid.ColumnDefinitions><ColumnDefinition Width="26"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
    <TextBlock x:Name="Ico" Grid.Column="0" Text="&#x25CB;" FontSize="15" FontWeight="Bold" VerticalAlignment="Center"/>
    <TextBlock x:Name="Nm" Grid.Column="1" Text="" FontSize="13" Foreground="#FFDDE7F0" VerticalAlignment="Center" TextWrapping="Wrap"/>
    <TextBlock x:Name="Dt" Grid.Column="2" Text="" FontSize="11.5" FontFamily="Consolas" Foreground="#FF7FB2C8" VerticalAlignment="Center" TextAlignment="Right" Margin="10,0,0,0"/>
  </Grid>
</Border>
"@
function New-StepRow([string]$name,$icoColor){
    $r=[Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader ([xml]$rowXaml)))
    $o=@{ Row=$r; Ico=$r.FindName('Ico'); Nm=$r.FindName('Nm'); Dt=$r.FindName('Dt') }
    $o.Nm.Text=$name; $o.Ico.Foreground=$icoColor; return $o
}
function Add-Row([string]$name,[string]$detail,$col,[string]$icoChar){
    $r=New-StepRow $name $col
    if($icoChar){ $r.Ico.Text=$icoChar }
    if($detail){ $r.Dt.Text=$detail; $r.Dt.Foreground=$col }
    $StepPanel.Children.Add($r.Row)|Out-Null; return $r
}
$killRowXaml = @"
<Border xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Background="#FF0E1C2E" CornerRadius="7" Padding="11,7" Margin="0,0,0,7">
  <Grid>
    <Grid.ColumnDefinitions><ColumnDefinition Width="24"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/><ColumnDefinition Width="8"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
    <TextBlock x:Name="Ico" Grid.Column="0" Text="&#x25CF;" FontSize="14" FontWeight="Bold" VerticalAlignment="Center"/>
    <TextBlock x:Name="Nm" Grid.Column="1" Text="" FontSize="13" Foreground="#FFDDE7F0" VerticalAlignment="Center" TextWrapping="Wrap"/>
    <TextBlock x:Name="Dt" Grid.Column="2" Text="" FontSize="11.5" FontFamily="Consolas" Foreground="#FF7FB2C8" VerticalAlignment="Center" TextAlignment="Right" Margin="8,0,0,0"/>
    <Button x:Name="Kill" Grid.Column="4" Content="Terminar" Width="96" Height="30" FontSize="11.5" FontWeight="Bold" Foreground="#FFFF9A9A" Background="#FF241016" BorderBrush="#FFB23A3A" BorderThickness="1.2" Cursor="Hand">
      <Button.Template><ControlTemplate TargetType="Button"><Border Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="6"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/></Border></ControlTemplate></Button.Template>
    </Button>
  </Grid>
</Border>
"@
function New-KillRow([string]$name,[string]$detail,$col){
    $r=[Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader ([xml]$killRowXaml)))
    $o=@{ Row=$r; Ico=$r.FindName('Ico'); Nm=$r.FindName('Nm'); Dt=$r.FindName('Dt'); Kill=$r.FindName('Kill') }
    $o.Nm.Text=$name; if($detail){ $o.Dt.Text=$detail }; $o.Ico.Foreground=$col
    return $o
}
function Attach-ProcMenu($krow,$procId){
    $kpid=$procId
        $krow.Kill.Content=([char]0x2699 + ' Acoes')
        $cm=New-Object System.Windows.Controls.ContextMenu
        $cm.Background=$cCard; $cm.Foreground=$cText
        $addItem={ param($text,$act) $mi=New-Object System.Windows.Controls.MenuItem; $mi.Header=$text; $mi.Foreground=$cText; $mi.Background=$cCard; $mi.Add_Click($act); $cm.Items.Add($mi)|Out-Null }
        & $addItem 'Terminar processo' ({ try{ Stop-Process -Id $kpid -Force -EA Stop; $krow.Ico.Text=[char]0x2713; $krow.Ico.Foreground=$cGreen; $krow.Dt.Text='terminado'; $krow.Dt.Foreground=$cGreen }catch{ $krow.Dt.Text='falhou'; $krow.Dt.Foreground=$cRed } }.GetNewClosure())
        & $addItem 'Suspender (congelar)' ({ try{ $h=(Get-Process -Id $kpid -EA Stop).Handle; [Native.Proc]::NtSuspendProcess($h)|Out-Null; $krow.Dt.Text='suspenso'; $krow.Dt.Foreground=$cAmber }catch{ $krow.Dt.Text='falhou'; $krow.Dt.Foreground=$cRed } }.GetNewClosure())
        & $addItem 'Retomar' ({ try{ $h=(Get-Process -Id $kpid -EA Stop).Handle; [Native.Proc]::NtResumeProcess($h)|Out-Null; $krow.Dt.Text='retomado'; $krow.Dt.Foreground=$cGreen }catch{ $krow.Dt.Text='falhou'; $krow.Dt.Foreground=$cRed } }.GetNewClosure())
        & $addItem 'Prioridade baixa' ({ try{ (Get-Process -Id $kpid -EA Stop).PriorityClass='Idle'; $krow.Dt.Text='prioridade baixa'; $krow.Dt.Foreground=$cAmber }catch{ $krow.Dt.Text='falhou'; $krow.Dt.Foreground=$cRed } }.GetNewClosure())
        & $addItem 'Prioridade normal' ({ try{ (Get-Process -Id $kpid -EA Stop).PriorityClass='Normal'; $krow.Dt.Text='prioridade normal'; $krow.Dt.Foreground=$cGreen }catch{ $krow.Dt.Text='falhou'; $krow.Dt.Foreground=$cRed } }.GetNewClosure())
        & $addItem 'Abrir localizacao' ({ try{ $pp=(Get-Process -Id $kpid -EA Stop).Path; if($pp){ Start-Process explorer.exe ("/select,`"{0}`"" -f $pp) } else { $krow.Dt.Text='sem caminho'; $krow.Dt.Foreground=$cAmber } }catch{ $krow.Dt.Text='falhou'; $krow.Dt.Foreground=$cRed } }.GetNewClosure())
        $krow.Kill.ContextMenu=$cm
        $krow.Kill.Add_Click({ $cm.PlacementTarget=$krow.Kill; $cm.IsOpen=$true }.GetNewClosure())
}

# ---------------- TEMPERATURAS (leitura ao vivo) ----------------
$DEG=[char]0x00B0
$tempCardXaml = @"
<Border xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Background="#FF0B1524" CornerRadius="9" Padding="11,8" Margin="0,0,0,9">
  <StackPanel>
    <Grid>
      <TextBlock x:Name="Lbl" Text="" FontSize="12" FontWeight="Bold" Foreground="#FF7FB2C8" VerticalAlignment="Center" HorizontalAlignment="Left"/>
      <TextBlock x:Name="Val" Text="--" FontSize="21" FontWeight="Bold" Foreground="#FFF2FFFF" HorizontalAlignment="Right" VerticalAlignment="Center"/>
    </Grid>
    <ProgressBar x:Name="Bar" Height="5" Minimum="0" Maximum="100" Value="0" Margin="0,7,0,0" Background="#FF0B1220" Foreground="#FF00E5FF" BorderThickness="0"/>
  </StackPanel>
</Border>
"@
function New-TempCard([string]$label){
    $r=[Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader ([xml]$tempCardXaml)))
    $o=@{ Row=$r; Lbl=$r.FindName('Lbl'); Val=$r.FindName('Val'); Bar=$r.FindName('Bar') }
    $o.Lbl.Text=$label; return $o
}
function Set-TempCard($card,$v,$crit=85){
    if($null -eq $v -or [double]$v -le 0){
        $card.Val.Text='N/D'; $card.Val.Foreground=$cFaint; $card.Bar.Value=0; $card.Bar.Foreground=$cFaint
        $card.Row.BorderThickness=[System.Windows.Thickness]::new(0)
    } else {
        $iv=[int][math]::Round([double]$v)
        $card.Val.Text=("{0}{1}C" -f $iv,$DEG)
        $col = if($iv -ge $crit){$cRed}elseif($iv -ge ($crit-15)){$cAmber}else{$cGreen}
        $card.Val.Foreground=$col; $card.Bar.Foreground=$col
        $card.Bar.Value=[math]::Max(0,[math]::Min(100,$iv))
        if($iv -ge $crit){ $card.Row.BorderBrush=$cRed; $card.Row.BorderThickness=[System.Windows.Thickness]::new(1.6) } else { $card.Row.BorderThickness=[System.Windows.Thickness]::new(0) }
    }
}
$TC=@{}
$TC.cpu = New-TempCard 'CPU'
$TC.gpu = New-TempCard 'GPU'
$TC.disk= New-TempCard 'DISCO'
$TC.mobo= New-TempCard 'PLACA'
foreach($k in 'cpu','gpu','disk','mobo'){ $TempPanel.Children.Add($TC[$k].Row)|Out-Null }
$TC.mobo.Row.Visibility='Collapsed'
$SC=@{}
$SC.cpu=New-TempCard 'USO CPU'
$SC.ram=New-TempCard 'USO RAM'
$SC.net=New-TempCard 'REDE'
foreach($k in 'cpu','ram','net'){ $SysPanel.Children.Add($SC[$k].Row)|Out-Null }
$SC.net.Bar.Visibility='Collapsed'; $SC.net.Val.FontSize=13
$script:netPrev=$null
function Set-UsePct($card,$v){
    if($null -eq $v){ $card.Val.Text='--'; return }
    $iv=[int]$v; $card.Val.Text="$iv%"; $card.Bar.Value=[math]::Max(0,[math]::Min(100,$iv))
    $col=if($iv -ge 90){$cRed}elseif($iv -ge 70){$cAmber}else{$cGreen}; $card.Val.Foreground=$col; $card.Bar.Foreground=$col
}
function Update-System {
    try{
        $cpuP=$null; try{ $cpuP=[int]((Get-CimInstance Win32_PerfFormattedData_PerfOS_Processor -EA Stop | Where-Object { $_.Name -eq '_Total' }).PercentProcessorTime) }catch{}
        Set-UsePct $SC.cpu $cpuP
        try{ $os=Get-CimInstance Win32_OperatingSystem -EA Stop; if($os.TotalVisibleMemorySize){ $usd=[int]((($os.TotalVisibleMemorySize-$os.FreePhysicalMemory)/$os.TotalVisibleMemorySize)*100); Set-UsePct $SC.ram $usd } }catch{}
        try{
            $rx=0;$tx=0; foreach($a in (Get-NetAdapterStatistics -EA SilentlyContinue)){ $rx+=[int64]$a.ReceivedBytes; $tx+=[int64]$a.SentBytes }
            $now=Get-Date
            if($script:netPrev){ $dt=($now-$script:netPrev.T).TotalSeconds; if($dt -gt 0){ $dRx=[math]::Max(0,[int](($rx-$script:netPrev.Rx)/$dt/1KB)); $dTx=[math]::Max(0,[int](($tx-$script:netPrev.Tx)/$dt/1KB)); $SC.net.Val.Text=("D:{0} S:{1} KB/s" -f $dRx,$dTx) } }
            $script:netPrev=@{ Rx=$rx; Tx=$tx; T=$now }
        }catch{}
    }catch{}
}

$script:lastDiskT=$null
# --- Sensores reais em PROCESSO SEPARADO, com as DLLs ao lado do programa ---
$script:appDir=$env:OTIM_DIR
if(-not $script:appDir){ try{ $script:appDir=(Get-Location).Path }catch{} }
$script:senFile=Join-Path $env:TEMP 'otim_temps.txt'
$script:senProc=$null
$script:engineMissing=$false
function Start-SensorWorker {
    try{
        $lhmP=Join-Path $script:appDir 'LibreHardwareMonitorLib.dll'
        if(-not (Test-Path $lhmP)){ $script:engineMissing=$true; return }
        Remove-Item $script:senFile -Force -EA SilentlyContinue
        $work=Join-Path $env:TEMP 'otim_worker.ps1'
        $wcode=@'
$dllDir=$args[0]; $out=Join-Path $env:TEMP 'otim_temps.txt'
try{
 [Reflection.Assembly]::LoadFrom((Join-Path $dllDir 'HidSharp.dll'))|Out-Null
 [Reflection.Assembly]::LoadFrom((Join-Path $dllDir 'LibreHardwareMonitorLib.dll'))|Out-Null
 $c=New-Object LibreHardwareMonitor.Hardware.Computer
 $c.IsCpuEnabled=$true;$c.IsGpuEnabled=$true;$c.IsMotherboardEnabled=$true;$c.IsStorageEnabled=$true
 $c.Open()
 while($true){
  $cv=@();$gv=@();$dv=@();$mv=@()
  foreach($hw in $c.Hardware){ $hw.Update(); foreach($sh in $hw.SubHardware){ $sh.Update(); foreach($s in $sh.Sensors){ if("$($s.SensorType)" -eq 'Temperature' -and $null -ne $s.Value){ $mv+=[double]$s.Value } } }; $ht="$($hw.HardwareType)"; foreach($s in $hw.Sensors){ if("$($s.SensorType)" -eq 'Temperature' -and $null -ne $s.Value){ $v=[double]$s.Value; if($ht -eq 'Cpu'){$cv+=$v}elseif($ht -like 'Gpu*'){$gv+=$v}elseif($ht -eq 'Storage'){$dv+=$v}elseif($ht -eq 'Motherboard'){$mv+=$v} } } }
  $cpu=if($cv.Count){($cv|Measure-Object -Maximum).Maximum}else{''}
  $gpu=if($gv.Count){($gv|Measure-Object -Maximum).Maximum}else{''}
  $disk=if($dv.Count){($dv|Measure-Object -Maximum).Maximum}else{''}
  $mobo=if($mv.Count){($mv|Measure-Object -Maximum).Maximum}else{''}
  "$cpu;$gpu;$disk;$mobo"|Set-Content -LiteralPath $out -Encoding ASCII
  Start-Sleep -Seconds 1
 }
}catch{ "ERR"|Set-Content -LiteralPath $out -Encoding ASCII }
'@
        Set-Content -LiteralPath $work -Value $wcode -Encoding UTF8
        $script:senProc=Start-Process powershell -PassThru -WindowStyle Hidden -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-WindowStyle','Hidden','-File',$work,$script:appDir
    }catch{}
}
function Get-Temps([switch]$SkipDisk){
    $src='Nativo'; $cpu=$null;$gpu=$null;$disk=$null;$mobo=$null
    try{
        if(Test-Path $script:senFile){
            $age=((Get-Date)-(Get-Item $script:senFile).LastWriteTime).TotalSeconds
            if($age -lt 6){
                $line=(Get-Content -LiteralPath $script:senFile -TotalCount 1)
                if($line -and $line -ne 'ERR'){
                    $p=$line -split ';'
                    if($p[0]){$cpu=[double]$p[0]}; if($p[1]){$gpu=[double]$p[1]}; if($p[2]){$disk=[double]$p[2]}; if($p.Count -gt 3 -and $p[3]){$mobo=[double]$p[3]}
                    if($cpu -or $gpu -or $disk -or $mobo){ $src='Sensores internos' }
                }
            }
        }
    }catch{}
    if(-not $cpu){ try{ $tz=Get-CimInstance -Namespace root/WMI -ClassName MSAcpi_ThermalZoneTemperature -EA Stop | Select-Object -First 1; if($tz){ $cpu=[math]::Round(($tz.CurrentTemperature/10)-273.15,0) } }catch{} }
    if(-not $gpu){ try{ $nv= & nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>$null; if($nv){ $gpu=[double](($nv|Select-Object -First 1).Trim()) } }catch{} }
    if(-not $SkipDisk){
        if(-not $disk){ try{ $dt=Get-PhysicalDisk -EA SilentlyContinue | Get-StorageReliabilityCounter -EA SilentlyContinue | Where-Object {$_.Temperature -gt 0} | Measure-Object -Property Temperature -Maximum; if($dt){ $disk=$dt.Maximum } }catch{} }
        $script:lastDiskT=$disk
    } elseif(-not $disk){ $disk=$script:lastDiskT }
    return @{ source=$src; cpu=$cpu; gpu=$gpu; disk=$disk; mobo=$mobo }
}
Start-SensorWorker
$script:tick=0
function Update-Temps {
    try{
        $script:tick++
        $engine=(Test-Path $script:senFile) -and (((Get-Date)-(Get-Item $script:senFile).LastWriteTime).TotalSeconds -lt 6)
        $skip=(-not $engine) -and -not ($script:tick -eq 1 -or ($script:tick % 6 -eq 0))
        $t=Get-Temps -SkipDisk:$skip
        Set-TempCard $TC.cpu $t.cpu; Set-TempCard $TC.gpu $t.gpu; Set-TempCard $TC.disk $t.disk 60
        if($t.mobo){ $TC.mobo.Row.Visibility='Visible'; Set-TempCard $TC.mobo $t.mobo } else { $TC.mobo.Row.Visibility='Collapsed' }
        try{ if($script:tray){ $script:tray.Text = if($t.cpu){ ('CPU ' + [int]$t.cpu + [char]0x00B0 + 'C') } else { 'Otimizador' } } }catch{}
        if($script:engineMissing){ $SrcTxt.Text='Fonte: Nativo (falta o motor ao lado)' } else { $SrcTxt.Text="Fonte: "+$t.source }
    }catch{}
}
$sensorTimer=New-Object System.Windows.Threading.DispatcherTimer
$sensorTimer.Interval=[TimeSpan]::FromSeconds(1)
$sensorTimer.Add_Tick({ Update-Temps; Update-System })
$win.Add_Loaded({ Update-Temps; Update-System; $sensorTimer.Start() })
$win.Add_Closed({ $sensorTimer.Stop(); try{ if($script:senProc -and -not $script:senProc.HasExited){ $script:senProc.Kill() } }catch{} })

# ---------------- Fechar apps 2o plano ----------------
$targetProcs=@('Code','Discord','Steam','steamwebhelper','EpicGamesLauncher','Spotify','Teams','ms-teams','Slack','chrome','msedge','firefox','opera','brave','vivaldi','WhatsApp','Telegram','Zoom')
function Get-OpenTargets { Get-Process -EA SilentlyContinue | Where-Object { $targetProcs -contains $_.ProcessName } | Select-Object -ExpandProperty ProcessName -Unique }
function Busy([bool]$b){ foreach($x in @($CloseApps,$Proc,$Lat,$Quick,$Deep)){ $x.IsEnabled = -not $b } }

$CloseApps.Add_Click({
    $before=@(Get-OpenTargets)
    foreach($n in $targetProcs){ Stop-Process -Name $n -Force -EA SilentlyContinue }
    Start-Sleep -Milliseconds 500
    if($before.Count -gt 0){ $Status.Text="Fechadas $($before.Count) apps: $($before -join ', ')" } else { $Status.Text="Nenhuma app de 2o plano estava aberta." }
})

# ---------------- Passos de limpeza ----------------
$steps = @(
  @{ n='Temporarios do utilizador e do sistema'; mode='quick'; a={ Clear-Folder $env:TEMP; Clear-Folder $env:TMP; Clear-Folder "$env:LOCALAPPDATA\Temp"; Clear-Folder "$env:WINDIR\Temp"; 'Concluido' } },
  @{ n='Prefetch'; mode='quick'; a={ Clear-Folder "$env:WINDIR\Prefetch"; 'Concluido' } },
  @{ n='Cache do Windows Update'; mode='quick'; a={ Stop-Service wuauserv,bits -Force -EA SilentlyContinue; Clear-Folder "$env:WINDIR\SoftwareDistribution\Download"; Start-Service wuauserv,bits -EA SilentlyContinue; 'Concluido' } },
  @{ n='Delivery Optimization'; mode='quick'; a={ Delete-DeliveryOptimizationCache -Force -EA SilentlyContinue; 'Concluido' } },
  @{ n='Miniaturas, icones e tipos de letra'; mode='quick'; a={ Get-ChildItem "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*.db","$env:LOCALAPPDATA\Microsoft\Windows\Explorer\iconcache_*.db" -EA SilentlyContinue | Remove-Item -Force -EA SilentlyContinue; 'Concluido' } },
  @{ n='Relatorios de erro e crash dumps'; mode='quick'; a={ Clear-Folder "$env:ProgramData\Microsoft\Windows\WER"; Clear-Folder "$env:LOCALAPPDATA\Microsoft\Windows\WER"; Clear-Folder "$env:LOCALAPPDATA\CrashDumps"; Remove-Item "$env:WINDIR\MEMORY.DMP" -Force -EA SilentlyContinue; Clear-Folder "$env:WINDIR\Minidump"; 'Concluido' } },
  @{ n='Cache dos navegadores (mantem logins)'; mode='quick'; a={ Clear-Folder "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache"; Clear-Folder "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache"; Get-ChildItem "$env:APPDATA\Mozilla\Firefox\Profiles" -Directory -EA SilentlyContinue | ForEach-Object { Clear-Folder "$($_.FullName)\cache2" }; 'Concluido' } },
  @{ n='Flush DNS e Reciclagem'; mode='quick'; a={ ipconfig /flushdns | Out-Null; Clear-RecycleBin -Force -EA SilentlyContinue; 'Concluido' } },
  @{ n='Cache da Store e registos de eventos'; mode='quick'; a={ Start-Process wsreset.exe -ArgumentList '-i' -WindowStyle Hidden -EA SilentlyContinue; $n=0; wevtutil el 2>$null | ForEach-Object { wevtutil cl "$_" 2>$null; $n++ }; "$n registos limpos" } },
  @{ n='Remover bloatware (apps inuteis)'; mode='deep'; a={ $apps=@('Microsoft.BingNews','Microsoft.BingWeather','Microsoft.BingFinance','Microsoft.BingSports','Microsoft.3DBuilder','Microsoft.Microsoft3DViewer','Microsoft.MicrosoftSolitaireCollection','Microsoft.MicrosoftOfficeHub','Microsoft.Office.OneNote','Microsoft.SkypeApp','Microsoft.GetHelp','Microsoft.Getstarted','Microsoft.WindowsFeedbackHub','Microsoft.WindowsMaps','Microsoft.Wallet','Microsoft.Messaging','Microsoft.MixedReality.Portal','Microsoft.People','Microsoft.Print3D','Microsoft.ZuneMusic','Microsoft.ZuneVideo','king.com.CandyCrushSaga','king.com.CandyCrushSodaSaga','Microsoft.Todos','Clipchamp.Clipchamp'); $r=0; foreach($x in $apps){ $pk=Get-AppxPackage -AllUsers $x -EA SilentlyContinue; if($pk){ $pk|Remove-AppxPackage -EA SilentlyContinue; $r++ }; Get-AppxProvisionedPackage -Online -EA SilentlyContinue | Where-Object { $_.DisplayName -eq $x } | Remove-AppxProvisionedPackage -Online -EA SilentlyContinue | Out-Null }; "$r apps removidas" } },
  @{ n='Desativar telemetria e diagnostico'; mode='deep'; a={ sc.exe stop DiagTrack *>$null; sc.exe config DiagTrack start= disabled *>$null; sc.exe stop dmwappushservice *>$null; sc.exe config dmwappushservice start= disabled *>$null; @('\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser','\Microsoft\Windows\Application Experience\ProgramDataUpdater','\Microsoft\Windows\Customer Experience Improvement Program\Consolidator','\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip') | ForEach-Object { schtasks /Change /TN $_ /Disable 2>$null | Out-Null }; reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f | Out-Null; $svc=Get-Service DiagTrack -EA SilentlyContinue; if($svc -and $svc.StartType -eq 'Disabled'){ 'Telemetria desativada' } else { 'Servico protegido pelo Windows; tarefas e politica aplicadas' } } },
  @{ n='Desativar Restauro do Sistema (permanente)'; mode='deep'; a={ vssadmin delete shadows /all /quiet 2>$null | Out-Null; try { Disable-ComputerRestore -Drive "$env:SystemDrive\" -EA Stop } catch {}; reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\SystemRestore" /v DisableSR /t REG_DWORD /d 1 /f | Out-Null; sc.exe config swprv start= disabled *>$null; 'Restauro desativado e pontos removidos' } },
  @{ n='Limpeza de Disco automatica'; mode='deep'; a={ $keys=@('Active Setup Temp Folders','BranchCache','Downloaded Program Files','Internet Cache Files','Memory Dump Files','Old ChkDsk Files','Previous Installations','Recycle Bin','Service Pack Cleanup','Setup Log Files','System error memory dump files','System error minidump files','Temporary Files','Temporary Setup Files','Thumbnail Cache','Update Cleanup','Upgrade Discarded Files','Windows Defender','Windows Error Reporting Files','Windows ESD installation files','Windows Upgrade Log Files'); foreach($k in $keys){ reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\$k" /v StateFlags0099 /t REG_DWORD /d 2 /f | Out-Null }; $p=Start-Process cleanmgr.exe -ArgumentList '/sagerun:99' -WindowStyle Hidden -PassThru -EA SilentlyContinue; if($p){ Wait-Proc $p 'Limpeza de Disco' }; 'Concluido' } },
  @{ n='Limpeza de componentes (DISM)'; mode='deep'; a={ $p=Start-Process dism.exe -ArgumentList '/online','/cleanup-image','/startcomponentcleanup' -WindowStyle Hidden -PassThru -EA SilentlyContinue; if($p){ Wait-Proc $p 'Limpeza de componentes'; "codigo $($p.ExitCode)" } else { 'Concluido' } } },
  @{ n='Reparacao da imagem do Windows (DISM)'; mode='deep'; a={ $p=Start-Process dism.exe -ArgumentList '/online','/cleanup-image','/restorehealth' -WindowStyle Hidden -PassThru -EA SilentlyContinue; if($p){ Wait-Proc $p 'Reparacao DISM'; "codigo $($p.ExitCode)" } else { 'Concluido' } } },
  @{ n='Verificacao de ficheiros do sistema (SFC)'; mode='deep'; a={ $p=Start-Process sfc.exe -ArgumentList '/scannow' -WindowStyle Hidden -PassThru -EA SilentlyContinue; if($p){ Wait-Proc $p 'Verificacao SFC'; "codigo $($p.ExitCode)" } else { 'Concluido' } } },
  @{ n='Otimizacao das unidades (TRIM / desfrag)'; mode='deep'; a={ $d=0; Get-Volume | Where-Object { $_.DriveLetter -and $_.DriveType -eq 'Fixed' } | ForEach-Object { Optimize-Volume -DriveLetter $_.DriveLetter -EA SilentlyContinue; $d++ }; "$d unidades otimizadas" } },
  @{ n='Plano de energia Alto Desempenho'; mode='deep'; a={ powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null | Out-Null; 'Ativado' } }
)

function Show-Summary([string]$title,[int]$freedMB,[int]$ok,[int]$fail,$elapsed){
    $SumTitle.Text=$title
    $OkCount.Text="$ok"; $FailCount.Text="$fail"; $TimeVal.Text=('{0:mm\:ss}' -f $elapsed)
    if($freedMB -ge 1024){ $FreedSub.Text=('espaco libertado  (~{0:N2} GB)' -f ($freedMB/1024)) } else { $FreedSub.Text='espaco libertado' }
    $Summary.Visibility='Visible'
    $target=[math]::Max(0,$freedMB); $st=[math]::Max(1,[math]::Ceiling($target/45)); $v=0
    while($v -lt $target){ $v+=$st; if($v -gt $target){$v=$target}; $FreedBig.Text=('{0:N0} MB' -f $v); Flush; Start-Sleep -Milliseconds 22 }
    $FreedBig.Text=('{0:N0} MB' -f $target)
}

function Run-Mode([string]$mode){
    Busy $true; $Summary.Visibility='Collapsed'; $Working.Visibility='Visible'; $StepPanel.Children.Clear()
    $sel=@(if($mode -eq 'deep'){ $steps } else { $steps | Where-Object { $_.mode -eq 'quick' } })
    $open=@(Get-OpenTargets)
    if($open.Count -gt 0){ $w=Add-Row ("Apps abertas: "+($open -join ', ')) 'usa FECHAR APPS' $cAmber '!' }
    $rows=@(); foreach($s in $sel){ $rows+=(Add-Row $s.n '' $cFaint) }
    Flush
    $t0=Get-Date; $before=FreeBytes; $ok=0; $fail=0
    for($i=0;$i -lt $sel.Count;$i++){
        $row=$rows[$i]; $row.Ico.Text=[char]0x25B6; $row.Ico.Foreground=$cCyan
        $Bar.IsIndeterminate=$false; $Bar.Value=[math]::Round(($i/$sel.Count)*100)
        $Status.Text="[$($i+1)/$($sel.Count)]  $($sel[$i].n)"; $row.Row.BringIntoView(); Flush
        try{ $res=& $sel[$i].a; if(-not $res){$res='Concluido'}; $row.Ico.Text=[char]0x2713; $row.Ico.Foreground=$cGreen; $row.Dt.Text="$res"; $row.Dt.Foreground=$cGreen; $ok++ }
        catch{ $row.Ico.Text=[char]0x2715; $row.Ico.Foreground=$cRed; $row.Dt.Text=("Falhou: "+$_.Exception.Message); $row.Dt.Foreground=$cRed; $fail++ }
        $Bar.IsIndeterminate=$false; Flush
    }
    $Bar.Value=100; $freedMB=[math]::Round(((FreeBytes)-$before)/1MB); if($freedMB -lt 0){$freedMB=0}
    $Working.Visibility='Collapsed'; $Status.Text='Concluido.'
    Show-Summary 'OTIMIZACAO CONCLUIDA' $freedMB $ok $fail ((Get-Date)-$t0)
    Busy $false
}
$Quick.Add_Click({ Run-Mode 'quick' })
$Deep.Add_Click({ Run-Mode 'deep' })

# ---------------- Analisar processos ----------------
$Proc.Add_Click({
    Busy $true; $Summary.Visibility='Collapsed'; $Working.Visibility='Visible'; $StepPanel.Children.Clear()
    Add-Row 'Varredura de processos em 2o plano' 'CPU=energia | ligacoes=rede' $cCyan '*' | Out-Null
    $Status.Text='A analisar processos (1s)...'; Flush
    $cores=[Environment]::ProcessorCount
    $s1=@{}; foreach($p in Get-Process -EA SilentlyContinue){ try{ $s1[$p.Id]=$p.CPU }catch{} }
    Start-Sleep -Milliseconds 1000; Flush
    $netMap=@{}; try{ Get-NetTCPConnection -State Established -EA SilentlyContinue | Group-Object OwningProcess | ForEach-Object { $netMap[[int]$_.Name]=$_.Count } }catch{}
    $list=@()
    foreach($p in Get-Process -EA SilentlyContinue){
        try{
            $d=$null; if($s1.ContainsKey($p.Id)){ $d=$p.CPU - $s1[$p.Id] }
            $cpu=0.0; if($d){ $cpu=[math]::Round(($d/$cores)*100,1); if($cpu -lt 0){$cpu=0} }
            $mem=[math]::Round($p.WorkingSet64/1MB)
            $conns=0; if($netMap.ContainsKey($p.Id)){ $conns=$netMap[$p.Id] }
            $bg = ($p.MainWindowHandle -eq 0)
            $score = $mem + ($cpu*25) + ($conns*20)
            $list += [pscustomobject]@{ Name=$p.ProcessName; Id=$p.Id; Mem=$mem; Cpu=$cpu; Conns=$conns; Bg=$bg; Score=$score }
        }catch{}
    }
    $top = $list | Sort-Object Score -Descending | Select-Object -First 12
    foreach($it in $top){
        $tag = if($it.Bg){'[2o plano] '}else{''}
        $col = if($it.Mem -ge 800 -or $it.Cpu -ge 25){$cRed}elseif($it.Mem -ge 300 -or $it.Cpu -ge 10){$cAmber}else{$cMuted}
        $row = New-KillRow ($tag+$it.Name) ("{0} MB | CPU {1}% | rede {2} lig" -f $it.Mem,$it.Cpu,$it.Conns) $col
        $StepPanel.Children.Add($row.Row) | Out-Null
        Attach-ProcMenu $row $it.Id
    }
    Add-Row 'Nota' 'bateria/largura de banda por app nao sao expostas pelo Windows; CPU e ligacoes sao os indicadores fiaveis' $cFaint 'i' | Out-Null
    $Working.Visibility='Collapsed'; $Status.Text='Analise de processos concluida.'; Busy $false
})

# ---------------- Testar latencia ----------------
$Lat.Add_Click({
    Busy $true; $Summary.Visibility='Collapsed'; $Working.Visibility='Visible'; $StepPanel.Children.Clear()
    Add-Row 'Teste de latencia (ping)' 'alvos: 1.1.1.1 e 8.8.8.8' $cCyan '*' | Out-Null
    foreach($tgt in @('1.1.1.1','8.8.8.8')){
        $times=@(); $loss=0
        for($i=1;$i -le 12;$i++){
            $Status.Text="Ping $tgt  ($i/12)..."; Flush
            $rt=$null; try{ $r=Test-Connection -ComputerName $tgt -Count 1 -EA Stop; $rt=[double]$r.ResponseTime }catch{ $loss++ }
            if($null -ne $rt){ $times+=$rt }
            Start-Sleep -Milliseconds 120
        }
        if($times.Count -gt 0){
            $min=($times|Measure-Object -Minimum).Minimum; $max=($times|Measure-Object -Maximum).Maximum
            $avg=[math]::Round(($times|Measure-Object -Average).Average,1)
            $jit=0.0; for($k=1;$k -lt $times.Count;$k++){ $jit+=[math]::Abs($times[$k]-$times[$k-1]) }; if($times.Count -gt 1){ $jit=[math]::Round($jit/($times.Count-1),1) }
            $col = if($avg -ge 80 -or $jit -ge 30){$cRed}elseif($avg -ge 40 -or $jit -ge 15){$cAmber}else{$cGreen}
            Add-Row $tgt ("media {0}ms | min {1} | max {2} | jitter {3}ms | perdas {4}/12" -f $avg,$min,$max,$jit,$loss) $col ([char]0x25CF) | Out-Null
        } else {
            Add-Row $tgt "sem resposta (12/12 perdidos)" $cRed ([char]0x2715) | Out-Null
        }
    }
    # processos com rede ativa durante o teste (suspeitos de lag)
    Add-Row 'Programas com mais rede ativa (possivel causa de picos)' '' $cCyan '*' | Out-Null
    try{
        $rows2=@()
        Get-NetTCPConnection -State Established -EA SilentlyContinue | Group-Object OwningProcess | ForEach-Object {
            $pid2=[int]$_.Name; $pp=Get-Process -Id $pid2 -EA SilentlyContinue
            if($pp -and $pid2 -gt 4){ $rows2 += [pscustomobject]@{ Id=$pid2; Name=$pp.ProcessName; Count=$_.Count; Path=$pp.Path } }
        }
        $winNames=@('svchost','System','Idle','lsass','services','wininit','csrss','smss','winlogon','dwm','fontdrvhost','spoolsv','SearchHost','RuntimeBroker','WmiPrvSE','dllhost','taskhostw','ctfmon','conhost','SearchIndexer','MsMpEng','SecurityHealthService','audiodg')
        $susp=$rows2 | Sort-Object Count -Descending | Select-Object -First 8
        if($susp){ foreach($s in $susp){
            $isWin = (-not $s.Path) -or ($s.Path -like "$env:WINDIR\\*") -or ($winNames -contains $s.Name)
            if($isWin){
                Add-Row ($s.Name + '  (sistema)') ("{0} ligacoes ativas" -f $s.Count) $cFaint ([char]0x25CF) | Out-Null
            } else {
                $row=New-KillRow $s.Name ("{0} ligacoes ativas" -f $s.Count) $cMuted
                $StepPanel.Children.Add($row.Row) | Out-Null
                Attach-ProcMenu $row $s.Id
            }
        } }
        else { Add-Row 'Sem processos com rede relevante' '' $cFaint '' | Out-Null }
    }catch{}
    Add-Row 'Nota' 'associacao pico<->programa e uma heuristica pela rede ativa, nao uma prova exata' $cFaint 'i' | Out-Null
    $Working.Visibility='Collapsed'; $Status.Text='Teste de latencia concluido.'; Busy $false
})

# ---------------- NITRO (perfil temporario de alto desempenho) ----------------
$script:nitroOn=$false; $script:nitroPrev=$null; $script:nitroPids=@()
$Nitro.Add_Click({
    if(-not $script:nitroOn){
        try{ $act=(powercfg /getactivescheme) -join ' '; if($act -match '([0-9a-fA-F-]{36})'){ $script:nitroPrev=$Matches[1] } }catch{}
        powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null | Out-Null
        try{ New-Item -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications' -Force | Out-Null; Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications' -Name ToastEnabled -Value 0 -Type DWord -EA SilentlyContinue }catch{}
        $me=$PID; $sid=(Get-Process -Id $PID).SessionId; $skip=@('System','Idle','csrss','wininit','winlogon','services','lsass','svchost','explorer','dwm','audiodg','powershell','conhost','fontdrvhost','SearchHost','StartMenuExperienceHost','ShellExperienceHost','ctfmon')
        $script:nitroPids=@(); $n=0
        foreach($p in Get-Process -EA SilentlyContinue){
            try{ if($p.Id -ne $me -and $p.SessionId -eq $sid -and $p.MainWindowHandle -eq 0 -and ($skip -notcontains $p.ProcessName) -and $p.PriorityClass -eq 'Normal'){ $p.PriorityClass='BelowNormal'; $script:nitroPids+=$p.Id; $n++ } }catch{}
        }
        $Nitro.Content='NITRO ATIVO'; $Status.Text="NITRO ligado: alto desempenho, notificacoes em silencio, $n processos abrandados."
        $script:nitroOn=$true
    } else {
        if($script:nitroPrev){ powercfg /setactive $script:nitroPrev 2>$null | Out-Null }
        try{ Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications' -Name ToastEnabled -Value 1 -Type DWord -EA SilentlyContinue }catch{}
        foreach($id in $script:nitroPids){ try{ $pp=Get-Process -Id $id -EA SilentlyContinue; if($pp){ $pp.PriorityClass='Normal' } }catch{} }
        $script:nitroPids=@()
        $Nitro.Content=[char]0x26A1+' NITRO'; $Status.Text='NITRO desligado: tudo reposto ao normal.'
        $script:nitroOn=$false
    }
})
$win.Add_Closed({ if($script:nitroOn){ if($script:nitroPrev){ powercfg /setactive $script:nitroPrev 2>$null | Out-Null }; try{ Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications' -Name ToastEnabled -Value 1 -Type DWord -EA SilentlyContinue }catch{}; foreach($id in $script:nitroPids){ try{ (Get-Process -Id $id -EA SilentlyContinue).PriorityClass='Normal' }catch{} } } })

# ================= FERRAMENTAS =================
function Show-Startup {
    Busy $true; $Summary.Visibility='Collapsed'; $Working.Visibility='Visible'; $StepPanel.Children.Clear()
    Add-Row 'Programas que arrancam com o Windows' 'Desativar remove do arranque (fica backup)' $cCyan '*' | Out-Null
    $bkp=Join-Path $env:APPDATA 'otim_startup_backup.txt'
    $any=$false
    foreach($k in @(@{P='HKCU:\Software\Microsoft\Windows\CurrentVersion\Run';H='HKCU'},@{P='HKLM:\Software\Microsoft\Windows\CurrentVersion\Run';H='HKLM'},@{P='HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run';H='HKLM32'})){
        try{ $props=Get-ItemProperty -Path $k.P -EA SilentlyContinue
            if($props){ foreach($pp in $props.PSObject.Properties){ if($pp.Name -notlike 'PS*'){
                $any=$true; $row=New-KillRow $pp.Name ('['+$k.H+']') $cMuted; $row.Kill.Content='Desativar'
                $StepPanel.Children.Add($row.Row)|Out-Null
                $rN=$pp.Name; $rP=$k.P; $rV=[string]$pp.Value; $rRow=$row; $rBkp=$bkp
                $row.Kill.Add_Click({ try{ Add-Content -LiteralPath $rBkp -Value ("{0}`t{1}`t{2}" -f $rP,$rN,$rV) -EA SilentlyContinue; Remove-ItemProperty -Path $rP -Name $rN -Force -EA Stop; $rRow.Ico.Text=[char]0x2713; $rRow.Ico.Foreground=$cGreen; $rRow.Dt.Text='desativado'; $rRow.Dt.Foreground=$cGreen; $rRow.Kill.IsEnabled=$false }catch{ $rRow.Dt.Text='falhou'; $rRow.Dt.Foreground=$cRed } }.GetNewClosure())
            } } }
        }catch{}
    }
    foreach($sf in @([Environment]::GetFolderPath('Startup'),(Join-Path $env:ProgramData 'Microsoft\Windows\Start Menu\Programs\StartUp'))){
        try{ Get-ChildItem -LiteralPath $sf -Filter *.lnk -EA SilentlyContinue | ForEach-Object {
            $any=$true; $row=New-KillRow $_.BaseName '[Pasta Arranque]' $cMuted; $row.Kill.Content='Desativar'
            $StepPanel.Children.Add($row.Row)|Out-Null
            $rF=$_.FullName; $rRow=$row
            $row.Kill.Add_Click({ try{ $dis=Join-Path (Split-Path $rF) '_desativados'; New-Item -ItemType Directory -Force -Path $dis|Out-Null; Move-Item -LiteralPath $rF -Destination $dis -Force -EA Stop; $rRow.Ico.Text=[char]0x2713; $rRow.Ico.Foreground=$cGreen; $rRow.Dt.Text='desativado'; $rRow.Dt.Foreground=$cGreen; $rRow.Kill.IsEnabled=$false }catch{ $rRow.Dt.Text='falhou'; $rRow.Dt.Foreground=$cRed } }.GetNewClosure())
        } }catch{}
    }
    if(-not $any){ Add-Row 'Nada no arranque' '' $cFaint '' | Out-Null }
    $Working.Visibility='Collapsed'; $Status.Text='Gestor de arranque.'; Busy $false
}
function Show-Uninstall {
    Busy $true; $Summary.Visibility='Collapsed'; $Working.Visibility='Visible'; $StepPanel.Children.Clear()
    Add-Row 'Programas instalados (maiores primeiro)' 'Desinstalar corre o desinstalador oficial' $cCyan '*' | Out-Null
    $items=@()
    foreach($root in 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall','HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall','HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall'){
        try{ Get-ChildItem $root -EA SilentlyContinue | ForEach-Object { $p=Get-ItemProperty $_.PSPath -EA SilentlyContinue; if($p.DisplayName -and $p.UninstallString){ $items += [pscustomobject]@{ Name=[string]$p.DisplayName; Size=[int]$p.EstimatedSize; Cmd=[string]$p.UninstallString } } } }catch{}
    }
    $items=$items | Sort-Object Size -Descending | Group-Object Name | ForEach-Object { $_.Group[0] } | Select-Object -First 25
    foreach($it in $items){
        $mb=if($it.Size){[math]::Round($it.Size/1024)}else{0}
        $row=New-KillRow $it.Name (if($mb){"$mb MB"}else{''}) $cMuted; $row.Kill.Content='Desinstalar'
        $StepPanel.Children.Add($row.Row)|Out-Null
        $rCmd=$it.Cmd; $rRow=$row
        $row.Kill.Add_Click({ try{ Start-Process cmd.exe -ArgumentList '/c',$rCmd; $rRow.Dt.Text='a desinstalar...'; $rRow.Dt.Foreground=$cAmber }catch{ $rRow.Dt.Text='falhou'; $rRow.Dt.Foreground=$cRed } }.GetNewClosure())
    }
    $Working.Visibility='Collapsed'; $Status.Text='Programas instalados.'; Busy $false
}
function Show-Health {
    Busy $true; $Summary.Visibility='Collapsed'; $Working.Visibility='Visible'; $StepPanel.Children.Clear()
    Add-Row 'Verificacao de saude' '' $cCyan '*' | Out-Null
    try{ Get-PSDrive -PSProvider FileSystem -EA SilentlyContinue | Where-Object { ($_.Used + $_.Free) -gt 0 } | ForEach-Object {
        $tot=$_.Used+$_.Free; $fp=[int](($_.Free/$tot)*100); $col=if($fp -lt 10){$cRed}elseif($fp -lt 20){$cAmber}else{$cGreen}
        Add-Row ('Disco '+$_.Name+':') ("{0}% livre ({1} GB)" -f $fp,[math]::Round($_.Free/1GB)) $col ([char]0x25CF) | Out-Null
    } }catch{}
    try{ Get-PhysicalDisk -EA SilentlyContinue | ForEach-Object { $col=if($_.HealthStatus -eq 'Healthy'){$cGreen}else{$cRed}; Add-Row ('SMART: '+$_.FriendlyName) ([string]$_.HealthStatus) $col ([char]0x25CF) | Out-Null } }catch{}
    try{ $os=Get-CimInstance Win32_OperatingSystem -EA Stop; $up=(Get-Date)-$os.LastBootUpTime; Add-Row 'Tempo ligado' ("{0}d {1}h {2}m" -f $up.Days,$up.Hours,$up.Minutes) $cMuted 'i' | Out-Null }catch{}
    try{ $pr=(Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending') -or (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'); $col=if($pr){$cAmber}else{$cGreen}; Add-Row 'Reinicio pendente' (if($pr){'SIM'}else{'nao'}) $col 'i' | Out-Null }catch{}
    $Working.Visibility='Collapsed'; $Status.Text='Verificacao de saude concluida.'; Busy $false
}
function Do-ResetNetwork {
    Busy $true; $Summary.Visibility='Collapsed'; $Working.Visibility='Visible'; $StepPanel.Children.Clear()
    Add-Row 'Repor rede' 'winsock + DNS + IP (pode pedir reinicio)' $cCyan '*' | Out-Null
    foreach($s in @(@{n='Flush DNS';c={ ipconfig /flushdns }},@{n='Reset Winsock';c={ netsh winsock reset }},@{n='Reset IP';c={ netsh int ip reset }},@{n='Libertar IP';c={ ipconfig /release }},@{n='Renovar IP';c={ ipconfig /renew }})){
        try{ & $s.c 2>$null | Out-Null; Add-Row $s.n 'ok' $cGreen ([char]0x2713) | Out-Null }catch{ Add-Row $s.n 'falhou' $cRed ([char]0x2715) | Out-Null }; Flush
    }
    Add-Row 'Nota' 'reinicia o PC para o winsock/IP assentarem' $cAmber 'i' | Out-Null
    $Working.Visibility='Collapsed'; $Status.Text='Rede reposta.'; Busy $false
}
function Do-RestartExplorer { try{ Stop-Process -Name explorer -Force -EA SilentlyContinue; $Status.Text='Explorador reiniciado.' }catch{ $Status.Text='falhou a reiniciar o Explorador.' } }
function Do-Schedule {
    try{
        $dir=Join-Path $env:ProgramData 'Otimizador'; New-Item -ItemType Directory -Force -Path $dir | Out-Null
        $cmdFile=Join-Path $dir 'limpeza.cmd'
        Set-Content -LiteralPath $cmdFile -Value "@echo off`r`ndel /f /s /q `"%TEMP%\*`" >nul 2>&1`r`ndel /f /s /q `"%WINDIR%\Temp\*`" >nul 2>&1`r`ndel /f /s /q `"%LOCALAPPDATA%\Temp\*`" >nul 2>&1" -Encoding ASCII
        schtasks /Create /TN 'Otim_LimpezaSemanal' /TR "\"$cmdFile\"" /SC WEEKLY /D SUN /ST 12:00 /RL HIGHEST /F 2>$null | Out-Null
        $Status.Text='Limpeza semanal agendada (domingo, 12:00).'
    }catch{ $Status.Text='falhou a agendar.' }
}
function Do-Unschedule { try{ schtasks /Delete /TN 'Otim_LimpezaSemanal' /F 2>$null | Out-Null; $Status.Text='Agendamento removido.' }catch{ $Status.Text='nao havia agendamento.' } }

# ===== ATUALIZACOES =====
$APP_VERSION='1.0'
$UPDATE_MANIFEST='https://raw.githubusercontent.com/SEU-UTILIZADOR/SEU-REPO/main/version.json'
try{ $VerTxt.Text=('v'+$APP_VERSION) }catch{}
function Get-RemoteInfo { try{ [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; return Invoke-RestMethod -Uri $UPDATE_MANIFEST -TimeoutSec 8 -EA Stop }catch{ return $null } }
function Is-NewerVer($rv){ try{ return ([version]([string]$rv)) -gt ([version]$APP_VERSION) }catch{ return ([string]$rv -ne [string]$APP_VERSION) } }
function Download-Update($remote){
    try{
        $self=$env:OTIM_SELF; if(-not $self -or -not (Test-Path $self)){ return $false }
        [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12
        $tmp="$self.new"
        Invoke-WebRequest -Uri $remote.url -OutFile $tmp -UseBasicParsing -TimeoutSec 40 -EA Stop
        $head=(Get-Content -LiteralPath $tmp -TotalCount 1 -EA SilentlyContinue)
        if((Get-Item $tmp).Length -lt 1000 -or ($head -notmatch 'echo off')){ Remove-Item $tmp -Force -EA SilentlyContinue; return $false }
        return $true
    }catch{ return $false }
}
function Do-CheckUpdate($silent){
    $r=Get-RemoteInfo
    if(-not $r){ if(-not $silent){ $Status.Text='Nao foi possivel verificar atualizacoes.' }; return }
    if(Is-NewerVer $r.version){
        $Status.Text=('Atualizacao disponivel: v'+[string]$r.version)
        $res=[System.Windows.MessageBox]::Show(("Nova versao v{0} disponivel.`n`n{1}`n`nAtualizar agora?" -f [string]$r.version,[string]$r.notes),'Otimizador - Atualizacao','YesNo','Information')
        if("$res" -eq 'Yes'){
            if(Download-Update $r){
                $self=$env:OTIM_SELF
                $hf=Join-Path $env:TEMP 'otim_update.cmd'
                Set-Content -LiteralPath $hf -Value "@echo off`r`ntimeout /t 2 >nul`r`nmove /y `"$self.new`" `"$self`" >nul`r`nstart `"`" `"$self`"" -Encoding ASCII
                Start-Process cmd.exe -ArgumentList '/c',$hf -WindowStyle Hidden
                [System.Windows.MessageBox]::Show('Atualizacao transferida. O programa vai reiniciar.','Otimizador','OK','Information')|Out-Null
                $win.Close()
            } else { [System.Windows.MessageBox]::Show('Nao consegui transferir/validar a atualizacao.','Otimizador','OK','Warning')|Out-Null }
        }
    } else { if(-not $silent){ $Status.Text=('Ja tens a versao mais recente (v'+$APP_VERSION+').') } }
}
$upTimer=New-Object System.Windows.Threading.DispatcherTimer
$upTimer.Interval=[TimeSpan]::FromSeconds(3)
$upTimer.Add_Tick({ $upTimer.Stop(); Do-CheckUpdate $true })
$win.Add_Loaded({ $upTimer.Start() })

$toolsMenu=New-Object System.Windows.Controls.ContextMenu
$toolsMenu.Background=$cCard; $toolsMenu.Foreground=$cText
function Add-ToolItem($text,$act){ $mi=New-Object System.Windows.Controls.MenuItem; $mi.Header=$text; $mi.Foreground=$cText; $mi.Background=$cCard; $mi.Add_Click($act); $toolsMenu.Items.Add($mi)|Out-Null }
Add-ToolItem 'Gestor de arranque' { Show-Startup }
Add-ToolItem 'Desinstalar programas' { Show-Uninstall }
Add-ToolItem 'Verificacao de saude' { Show-Health }
$toolsMenu.Items.Add((New-Object System.Windows.Controls.Separator)) | Out-Null
Add-ToolItem 'Repor rede' { Do-ResetNetwork }
Add-ToolItem 'Reiniciar Explorador' { Do-RestartExplorer }
$toolsMenu.Items.Add((New-Object System.Windows.Controls.Separator)) | Out-Null
Add-ToolItem 'Agendar limpeza semanal' { Do-Schedule }
Add-ToolItem 'Remover agendamento' { Do-Unschedule }
$toolsMenu.Items.Add((New-Object System.Windows.Controls.Separator)) | Out-Null
Add-ToolItem 'Procurar atualizacoes' { Do-CheckUpdate $false }
$Tools.ContextMenu=$toolsMenu
$Tools.Add_Click({ $toolsMenu.PlacementTarget=$Tools; $toolsMenu.IsOpen=$true })

# ================= BANDEJA (tray) =================
$script:tray=$null
try{
    Add-Type -AssemblyName System.Windows.Forms, System.Drawing
    $script:tray=New-Object System.Windows.Forms.NotifyIcon
    $script:tray.Icon=[System.Drawing.SystemIcons]::Information
    $script:tray.Text='Otimizador'
    $script:tray.Visible=$false
    $tm=New-Object System.Windows.Forms.ContextMenuStrip
    $tmO=$tm.Items.Add('Abrir'); $tmO.add_Click({ $win.Show(); $win.WindowState=[System.Windows.WindowState]::Normal; $win.Activate(); $script:tray.Visible=$false })
    $tmE=$tm.Items.Add('Sair'); $tmE.add_Click({ $script:tray.Visible=$false; $win.Close() })
    $script:tray.ContextMenuStrip=$tm
    $script:tray.add_MouseDoubleClick({ $win.Show(); $win.WindowState=[System.Windows.WindowState]::Normal; $win.Activate(); $script:tray.Visible=$false })
    $win.Add_StateChanged({ if($win.WindowState -eq [System.Windows.WindowState]::Minimized){ $win.Hide(); if($script:tray){ $script:tray.Visible=$true } } })
    $win.Add_Closed({ try{ if($script:tray){ $script:tray.Visible=$false; $script:tray.Dispose() } }catch{} })
}catch{}

for($sv=72;$sv -le 94;$sv+=3){ Set-Splash $sv 'A ligar sensores...'; Start-Sleep -Milliseconds 14 }
Set-Splash 100 'Pronto'
Start-Sleep -Milliseconds 170
$win.Add_Closed({ [System.Windows.Threading.Dispatcher]::CurrentDispatcher.InvokeShutdown() })
$win.Show()
$splash.Close()
[System.Windows.Threading.Dispatcher]::Run()
} catch {
    $emsg = $_.Exception.Message + [Environment]::NewLine + [Environment]::NewLine + $_.ScriptStackTrace
    try { $STxt.Text='ERRO ao arrancar'; $SPct.Text=''; Flush } catch {}
    [System.Windows.MessageBox]::Show($emsg, 'Otimizador - erro ao arrancar') | Out-Null
    try { $splash.Close() } catch {}
}
