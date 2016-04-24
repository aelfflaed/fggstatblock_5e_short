<?xml version="1.0" encoding="windows-1252"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml" version="1.0">
    <!--Frog God Games Style Short Statblock-->
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
    
    <!-- Quick template to insert a space somewhere, even if XSL would normally
     collapse it -->
    <xsl:template name="space">
        <xsl:text> </xsl:text>
    </xsl:template>
    
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
            <xsl:text> </xsl:text>
            
            <!-- Hit points -->
            <strong>HP </strong>
            <xsl:value-of select="health/@hitpoints"/>
            (<xsl:value-of select="health/@hitdice"/>);
            <xsl:text> </xsl:text>
            
            <!-- Add Speed -->
            <strong>Spd </strong>
            <xsl:value-of select="movement/basespeed/@value"/>ft
            <xsl:if test="count(movement/special) != 0">
                , <xsl:apply-templates select="movement/special/@name"/>
            </xsl:if>;
            
            <!-- Attacks  -->
            <xsl:if test="count(melee/weapon) != 0">
                <strong>Melee </strong>
                <xsl:apply-templates select="melee/weapon"/>;
                <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:if test="count(ranged/weapon) != 0">
                <strong>Ranged </strong>
                <xsl:apply-templates select="ranged/weapon"/>;
                <xsl:text> </xsl:text>
            </xsl:if>
            
            <!-- Special Abilities Action-->
            <strong>SA </strong>
            <xsl:for-each select="otherspecials/special">
                <xsl:if test="not(contains(@name, 'Legendary')) and not(contains(@name, 'Action'))">
                    <xsl:if test="position() != 1">
                        <xsl:text>,</xsl:text>
                    </xsl:if>
                    <xsl:value-of select="translate(@name, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
                </xsl:if>
            </xsl:for-each>;
            <xsl:text> </xsl:text>
            
            <!-- Legendary Actions Legendary-->
            <strong>LA </strong>;
            <xsl:for-each select="otherspecials/special">
                <xsl:if test="contains(@name, 'Legendary')">
                    <xsl:if test="position() != 1">
                        <xsl:text>,</xsl:text>
                    </xsl:if>
                    <xsl:value-of select="translate(@name, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
                </xsl:if>
            </xsl:for-each>;
            <xsl:text> </xsl:text>
            
            <!-- Add Immunities -->
            <xsl:if test="damageimmunities/@text != '' or conditionimmunities/@text != ''">
                <strong>Immune </strong>
                <xsl:value-of select="damageimmunities/@text"/>,
                <xsl:text> </xsl:text>
                <xsl:value-of select="conditionimmunities/@text"/>;
                <xsl:text> </xsl:text>
            </xsl:if>
            
            <!-- Add Resistances -->
            <xsl:if test="damageresistances/@text != ''">
                <strong>Resist </strong>
                <xsl:value-of select="damageresistances/@text"/>;
                <xsl:text> </xsl:text>
            </xsl:if>
            
            <!-- Ability scores -->
            <xsl:apply-templates select="abilityscores/abilityscore"/>;
            <xsl:text> </xsl:text>
            
            <!-- Skills -->
            <strong>Skills </strong>
            <xsl:apply-templates select="skills/skill"/>;
            <xsl:text> </xsl:text>
            
            <!-- Add Senses -->
            <strong>Senses </strong>
            <xsl:value-of select="senses/special/@name"/>,
            <!-- Add Senses -->
            passive Perception
            <xsl:for-each select="skills/skill[@name = 'Perception']">
                <xsl:value-of select="@passive"/>
            </xsl:for-each>;
            <xsl:text> </xsl:text>
            
            <!-- Add Traits Not Legendary or Action-->
            <strong>Traits </strong>;
            <xsl:for-each select="otherspecials/special">
                <xsl:if test="not(contains(@name, 'Legendary')) and not(contains(@name, 'Action'))">
                    <xsl:if test="position() != 1">
                        <xsl:text>,
                        </xsl:text>
                    </xsl:if>
                    <xsl:value-of select="translate(@name, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
                </xsl:if>
            </xsl:for-each>;
            <xsl:text> </xsl:text>
            
            <!-- Alignment -->
            <strong>AL </strong>
            <xsl:value-of select="alignment/@abbreviation"/>;
            <xsl:text> </xsl:text>
            
            <!-- Add Challenge Rating -->
            <strong>CR </strong>
            <xsl:value-of select="substring-after(challengerating/@text, ' ' )"/>;
            <xsl:text> </xsl:text>
            
            <!-- Add XP -->
            <strong>XP </strong>
            <xsl:value-of select="xpaward/@value"/>;
            <xsl:text> </xsl:text>
            
            <!-- Spells only listed if there are any, as a list with no items in it looks odd-->
            <xsl:if test="count(otherspecials/special[@name = 'innate Spellcasting']) != 0 or ">
                <strong>Innate Spells: </strong>
                <xsl:for-each select="otherspecials/special[@name = 'innate spellcasting']">
                    <xsl:value-of select="description"/>
                </xsl:for-each>,
                <xsl:text> </xsl:text>
            </xsl:if>
            
            <xsl:if test="count(otherspecials/special[@name = 'spellcasting']) != 0">
                <strong>Spells (slots): </strong>
                <xsl:for-each select="otherspecials/special[@name = 'spellcasting']">
                    <xsl:value-of select="description"/>
                </xsl:for-each>,
                <xsl:text> </xsl:text>
            </xsl:if>
            
            <!-- Spells powers only listed if there are any, otherwise we get a list
             with no items in it, which looks odd
             <xsl:if test="count(spellsknown/spell | spellsmemorized/spell) != 0">
             Spells (Slots): <xsl:apply-templates select="spellsknown/spell | spellsmemorized/spell"/>
             </xsl:if>
             <xsl:if test="count(spellbook/spell) != 0">
             Spells in Spellbook: <xsl:apply-templates select="spellbook/spell"/>
             </xsl:if>-->
        </p>
        
        <!-- And a horizontal rule to split between stat blocks -->
        <hr/>
    </xsl:template>
    
    <!-- These simple rules match ability scores -->
    <xsl:template match="abilityscore">
        <xsl:if test="position() != 1">
            <xsl:text>, </xsl:text>
        </xsl:if>
        <strong>
            <xsl:value-of select="substring(@name, 1, 3)"> </xsl:value-of>
        </strong>
        <xsl:value-of select="abilbonus/@text"/>
    </xsl:template>
    
    <!-- Skills -->
    <xsl:template match="skill">
        <xsl:if test="@isproficient='yes'">
            <xsl:if test="position() != 1">
                <xsl:text>, </xsl:text>
            </xsl:if>
            <xsl:value-of select="@name"/>
            <xsl:text> </xsl:text>
            <xsl:if test="@value >= 0">+</xsl:if>
            <xsl:value-of select="@value"/>
        </xsl:if>
    </xsl:template>
    
    <!-- Add a comma before all movements but the first -->
    <xsl:template match="movement">
        <xsl:if test="position() != 1">
            <xsl:text>, </xsl:text>
        </xsl:if>
        <xsl:value-of select="@name"/>
    </xsl:template>
    
    <!-- Weapons -->
    <xsl:template match="weapon">
        <xsl:if test="position() != 1">
            <xsl:text>, </xsl:text>
        </xsl:if>
        <xsl:value-of select="@name"/>
        (<xsl:value-of select="@attack"/>,
        <xsl:value-of select="substring-before(substring-after(@damage, '(' ), ')' ) "/>
        <xsl:value-of select="substring-after(@damage, ')' )"/>)
    </xsl:template>
    
    <!-- Spells-->
     <xsl:template match="spell">
     <xsl:if test="position() != 1"><xsl:text>, </xsl:text>
     </xsl:if><xsl:value-of select="@name"/> </xsl:template>
    
</xsl:stylesheet>