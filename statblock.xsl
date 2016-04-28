<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml" version="1.0">
    <xsl:output encoding="utf-8" method="html" />
    
    <xsl:template match="/">
        
        <!-- Add a proper DOCTYPE declaration here, to make sure the page is rendered
         properly. Firefox doesn't need this, so we make sure it doesn't get
         output when we're using "Transformiix", the Firefox XSLT processor.
         NOTE: This weird behaviour is only an issue if you have this stylesheet
         directly linked from an XML document, i.e. if you're trying to test
         it without having to tell HL to regenerate the XML file every time.
         -->
        <xsl:if test="system-property('xsl:vendor') != 'Transformiix'">
            <xsl:text disable-output-escaping="yes">
                &lt;!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
                "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"&gt;
            </xsl:text>
        </xsl:if>
        <html>
            <head>
                <!--Frog God Games Style Short Statblock-->
                <!-- XHTML requires that you specify a meta-tag to dictate the content type.-->
                <xsl:text disable-output-escaping="yes">
                    &lt;meta http-equiv="Content-Type" content="text/html;charset=ISO-8859-1"/&gt;
                </xsl:text>
                
                <style type="text/css">
                    body {
                    font-family: serif;
                    text-align: left;
                    font-size: 12pt;
                    }
                </style>
                
                <!-- Page title - just find the first character and use its name  -->
                <title><xsl:value-of select="/document/public/character/@name"/></title>
            </head>
            
            <body>
                <!-- Output all our character nodes in turn
                 NOTE: We use //character to ensure that we pick up minions as well, since
                 they're children of characters
                 -->
                <xsl:apply-templates select="/document/public//character"/>
            </body>
        </html>
    </xsl:template>
    
    <!-- Quick template to insert a  somewhere, even if XSL would normally
     collapse it -->
    <xsl:template name="space">&#160;</xsl:template>
    
    <!-- How to output each character in the document -->
    <xsl:template match="character">
        <p>
            <!--  Name , Skip blank player name-->
            <strong>
                <xsl:value-of select="race/@name"/>:
            </strong>
            
            <!-- Attack bonuses & Armor Class-->
            <strong>AC </strong>
            <xsl:value-of select="armorclass/@ac"/>;
            
            
            <!-- Hit points -->
            <strong>HP </strong>
            <xsl:value-of select="health/@hitpoints"/>
            (<xsl:value-of select="health/@hitdice"/>);<xsl:call-template name="space"/>
            
            
            <!-- Add Speed-->
            <strong>Spd </strong>
            <xsl:value-of select="movement/basespeed/@value"/>ft
            <xsl:if test="count(movement/special) != 0">
                <xsl:for-each select="movement/special">
                    ,<xsl:call-template name="space"/>
                    <xsl:value-of select="@name"/>
                </xsl:for-each>
            </xsl:if>;
            <xsl:call-template name="space"/>
            
            <!-- Attacks  -->
            <xsl:if test="count(melee/weapon) != 0">
                <strong>Melee </strong>
                <xsl:apply-templates select="melee/weapon"/>;<xsl:call-template name="space"/>
            </xsl:if>
            <xsl:if test="count(ranged/weapon) != 0">
                <strong>Ranged </strong>
                <xsl:apply-templates select="ranged/weapon"/>;<xsl:call-template name="space"/>
            </xsl:if>
            
            <!-- Special Abilities Action-->
            <xsl:if test="count(otherspecials/special[(contains(@name, 'Action'))]) != 0 and count(otherspecials/special[not(contains(@name, 'Legendary'))]) != 0 ">
                <strong>SA </strong>
                <xsl:for-each select="otherspecials/special">
                    <xsl:if test="not(contains(@name, 'Legendary')) and (contains(@name, 'Action'))">
                        <xsl:if test="position() != 1">,<xsl:call-template name="space"/>
                        </xsl:if>
                        <xsl:value-of select="translate(@name, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
                    </xsl:if>
                </xsl:for-each>;<xsl:call-template name="space"/>
            </xsl:if>
            
            <!-- Legendary Actions Legendary-->
            <xsl:if test="count(otherspecials/special[contains(@name, 'Legendary')]) != 0 ">
                <strong>LA </strong>
                <xsl:for-each select="otherspecials/special">
                    <xsl:if test="contains(@name, 'Legendary')">
                        <xsl:if test="position() != 1">,<xsl:call-template name="space"/>
                        </xsl:if>
                        <xsl:value-of select="translate(@name, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
                    </xsl:if>
                </xsl:for-each>;<xsl:call-template name="space"/>
            </xsl:if>
            
            <!-- Add Immunities-->
            <xsl:if test="damageimmunities/@text != '' or conditionimmunities/@text != ''">
                <strong>Immune </strong>
                <xsl:value-of select="damageimmunities/@text"/>,<xsl:call-template name="space"/>
                <xsl:value-of select="conditionimmunities/@text"/>;<xsl:call-template name="space"/>
            </xsl:if>
            
            <!-- Add Resistances-->
            <xsl:if test="damageresistances/@text != ''">
                <strong>Resist </strong>
                <xsl:value-of select="damageresistances/@text"/>;<xsl:call-template name="space"/>
            </xsl:if>
            
            <!-- Ability scores -->
            <xsl:apply-templates select="abilityscores/abilityscore"/>;<xsl:call-template name="space"/>
            
            <!-- Skills -->
            <xsl:if test="count(skills/skill[@isproficient='yes']) != 0 ">
                <strong>Skills </strong>
                <xsl:for-each select="skills/skill[@isproficient='yes']">
                    <xsl:if test="position() != 1">
                        ,<xsl:call-template name="space"/>
                    </xsl:if>
                    <xsl:value-of select="@name"/><xsl:call-template name="space"/>
                    <xsl:if test="@value >= 0">+</xsl:if><xsl:value-of select="@value"/>
                </xsl:for-each>;<xsl:call-template name="space"/>
            </xsl:if>
            
            <!-- Add Senses -->
            <strong>Senses </strong>
            <xsl:for-each select="senses/special">
                <xsl:if test="position() != 1">
                    ,<xsl:call-template name="space"/>
                </xsl:if>
                <xsl:value-of select="@name"/>
            </xsl:for-each>
            <xsl:call-template name="space"/>
            
            <!-- Add Senses -->
            passive Perception
            <xsl:for-each select="skills/skill[@name = 'Perception']">
                <xsl:value-of select="@passive"/>
            </xsl:for-each>;<xsl:call-template name="space"/>
            
            <!-- Add Traits Not Legendary or Action-->
            <xsl:if test="count(otherspecials/special[not(contains(@name, 'Action'))]) != 0 or count(otherspecials/special[contains(@name, 'Legendary')]) != 0 ">
                <strong>Traits </strong>
                <xsl:for-each select="otherspecials/special">
                    <xsl:if test="not(contains(@name, 'Legendary' )) and not(contains(@name, 'Action' ))">
                        <xsl:if test="position() != 1">
                            ,<xsl:call-template name="space"/>
                        </xsl:if>
                        <xsl:value-of select="translate(@name, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
                    </xsl:if>
                </xsl:for-each>;<xsl:call-template name="space"/>
            </xsl:if>
            
            <!-- Alignment-->
            <strong>AL </strong>
            <xsl:value-of select="alignment/@abbreviation"/>;<xsl:call-template name="space"/>
            
            <!-- Add Challenge Rating-->
            <xsl:if test="challengerating">
                <strong>CR </strong>
                <xsl:value-of select="substring-after(challengerating/@text, ' ' )"/>;<xsl:call-template name="space"/>
            </xsl:if>
            
            <!-- Add XP-->
            <xsl:if test="xpaward">
                <strong>XP </strong>
                <xsl:value-of select="xpaward/@value"/>.<xsl:call-template name="space"/>
            </xsl:if>
            
            <!-- Innate Spellcasting-->
            <xsl:if test="count(otherspecials/special[@name = 'Innate Spellcasting']) != 0 ">
                <br/>
                <xsl:call-template name="space"/> <xsl:call-template name="space"/> <xsl:call-template name="space"/>
                <xsl:call-template name="space"/> <xsl:call-template name="space"/><xsl:call-template name="space"/>
                <strong>Innate Spells: </strong>
                
                <xsl:for-each select="otherspecials/special[@name = 'Innate Spellcasting']">
                    <xsl:value-of select="@description"/>.<xsl:call-template name="space"/>
                </xsl:for-each>
            </xsl:if>
            
            <!-- Non-Innate Spellcasting-->
            <xsl:if test="count(otherspecials/special[@name = 'Spellcasting']) != 0 ">
                <xsl:for-each select="otherspecials/special[@name = 'Spellcasting']">
                    <xsl:value-of select="@description"/>.<xsl:call-template name="space"/>
                </xsl:for-each>
            </xsl:if>
            
            <!-- Cantrips and Memorized spells-->
            <xsl:if test="count(cantrips/spell) != 0 or count(spellsmemorized/spell) != 0 ">
                <br/>
                <xsl:call-template name="space"/><xsl:call-template name="space"/><xsl:call-template name="space"/>
                <xsl:call-template name="space"/><xsl:call-template name="space"/><xsl:call-template name="space"/>
                <strong>Spells (slots): </strong>
                
                <xsl:if test="count(cantrips/spell) != 0">
                    0 (at will)&#8212;
                    <xsl:apply-templates select="cantrips/spell"/>;
                </xsl:if>
                
                <xsl:if test="count(spellslots/spellslot[@name = '1st']) != 0">
                    <xsl:for-each select="spellslots/spellslot[@name = '1st']">
                        1st(<xsl:value-of select="count"/>)
                    </xsl:for-each>
                    &#8212;<xsl:apply-templates select="spellsmemorized/spell[@level = '1']"/>;<xsl:call-template name="space"/>
                </xsl:if>
                
                <xsl:if test="count(spellslots/spellslot[@name = '2nd']) != 0">
                    <xsl:for-each select="spellslots/spellslot[@name = '2nd']">
                        2nd(<xsl:value-of select="count"/>)
                    </xsl:for-each>
                    &#8212;<xsl:apply-templates select="spellsmemorized/spell[@level = '2']"/>;<xsl:call-template name="space"/>
                </xsl:if>
                
                <xsl:if test="count(spellslots/spellslot[@name = '3rd']) != 0">
                    <xsl:for-each select="spellslots/spellslot[@name = '3rd']">
                        3rd(<xsl:value-of select="count"/>)
                    </xsl:for-each>
                    &#8212;<xsl:apply-templates select="spellsmemorized/spell[@level = '3']"/>;<xsl:call-template name="space"/>
                </xsl:if>
                
                <xsl:if test="count(spellslots/spellslot[@name = '4th']) != 0">
                    <xsl:for-each select="spellslots/spellslot[@name = '4th']">
                        4th(<xsl:value-of select="count"/>)
                    </xsl:for-each>
                    &#8212;<xsl:apply-templates select="spellsmemorized/spell[@level = '4']"/>;<xsl:call-template name="space"/>
                </xsl:if>
                
                <xsl:if test="count(spellslots/spellslot[@name = '5th']) != 0">
                    <xsl:for-each select="spellslots/spellslot[@name = '5th']">
                        5th(<xsl:value-of select="count"/>)
                    </xsl:for-each>
                    &#8212;<xsl:apply-templates select="spellsmemorized/spell[@level = '5']"/>;<xsl:call-template name="space"/>
                </xsl:if>
                
                <xsl:if test="count(spellslots/spellslot[@name = '6th']) != 0">
                    <xsl:for-each select="spellslots/spellslot[@name = '6th']">
                        6th(<xsl:value-of select="count"/>)
                    </xsl:for-each>
                    &#8212;<xsl:apply-templates select="spellsmemorized/spell[@level = '6']"/>;<xsl:call-template name="space"/>
                </xsl:if>
                
                <xsl:if test="count(spellslots/spellslot[@name = '7th']) != 0">
                    <xsl:for-each select="spellslots/spellslot[@name = '7th']">
                        7th(<xsl:value-of select="count"/>)
                    </xsl:for-each>
                    &#8212;<xsl:apply-templates select="spellsmemorized/spell[@level = '7']"/>;<xsl:call-template name="space"/>
                </xsl:if>
                
                <xsl:if test="count(spellslots/spellslot[@name = '8th']) != 0">
                    <xsl:for-each select="spellslots/spellslot[@name = '8th']">
                        8th(<xsl:value-of select="count"/>)
                    </xsl:for-each>
                    &#8212;<xsl:apply-templates select="spellsmemorized/spell[@level = '8']"/>;<xsl:call-template name="space"/>
                </xsl:if>
                
                <xsl:if test="count(spellslots/spellslot[@name = '9th']) != 0">
                    <xsl:for-each select="spellslots/spellslot[@name = '9th']">
                        9th(<xsl:value-of select="count"/>)
                    </xsl:for-each>
                    &#8212;<xsl:apply-templates select="spellsmemorized/spell[@level = '9']"/>;<xsl:call-template name="space"/>
                </xsl:if>
            </xsl:if>
            
            <!-- And a horizontal rule to split between stat blocks -->
            <hr/>
        </p>
    </xsl:template>
    
    <!-- These simple rules match ability scores -->
    <xsl:template match="abilityscore">
        <xsl:if test="position() != 1">,<xsl:call-template name="space"/>
        </xsl:if>
        <strong><xsl:value-of select="substring(@name, 1, 3)"/></strong>
        <xsl:call-template name="space"/>
        <xsl:value-of select="abilbonus/@text"/>
    </xsl:template>
    
    <!-- Weapons-->
    <xsl:template match="weapon">
        <xsl:if test="position() != 1">,<xsl:call-template name="space"/>
        </xsl:if>
        
        <xsl:choose>
            <xsl:when test="contains(@name, '(')">
                <xsl:value-of select="substring-before(@name, '(' ) "/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="@name"/>
            </xsl:otherwise>
        </xsl:choose>
        
        (<xsl:value-of select="@attack"/>,<xsl:call-template name="space"/>
        <xsl:choose>
            <xsl:when test="contains(@damage, '(')">
                <xsl:value-of select="substring-before(substring-after(@damage, '(' ), ')' ) "/>
                <xsl:value-of select="substring-after(@damage, ')' )"/>
            </xsl:when>
            
            <xsl:otherwise>
                <xsl:value-of select="@damage"/>
            </xsl:otherwise>
        </xsl:choose>)
    </xsl:template>
    
    <!-- Spells-->
    <xsl:template match="spell">
        <xsl:if test="position() != 1">,<xsl:call-template name="space"/>
        </xsl:if>
        <xsl:value-of select="translate(@name, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
    </xsl:template>
    
</xsl:stylesheet>
