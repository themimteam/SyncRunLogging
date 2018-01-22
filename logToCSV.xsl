<?xml version="1.0"?>
<!--

Copyright (c) 2014, Unify Solutions Pty Ltd
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; 
OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


Written by Carol Wapshere

Performs transformation of an run profile import/export log file.
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:a="http://www.microsoft.com/mms/mmsml/v2" xmlns:data="http://example.com/data">
<xsl:output media-type="text" omit-xml-declaration="yes"  encoding="ANSI" indent="no" />
<xsl:param name="starttime"/>
<xsl:param name="maname"/>
<xsl:template match="/">StartTime;MAName;DN;ChangeType;Attribute;Operation;AddValue;DeleteValue
<xsl:for-each select="a:mmsml/a:directory-entries/a:delta">
<!-- Renames -->
<xsl:choose>
<xsl:when test = "@newdn">
<xsl:value-of select="$starttime" />;<xsl:value-of select="$maname" />;<xsl:value-of select="@dn" disable-output-escaping="yes" />;rename;DN;modify;<xsl:value-of select="@newdn" disable-output-escaping="yes" />;<xsl:value-of select="@dn" disable-output-escaping="yes" /><xsl:text>&#10;</xsl:text>
</xsl:when>
<xsl:otherwise>

<!-- Reference attributes -->
<xsl:for-each select="a:dn-attr">

<!-- Multi-valued -->
<xsl:if test = "@multivalued='true'">
<xsl:for-each select="a:dn-value">
<xsl:choose>
<xsl:when test = "@operation='delete'">
<xsl:value-of select="$starttime" />;<xsl:value-of select="$maname" />;<xsl:value-of select="../../@dn" disable-output-escaping="yes" />;<xsl:value-of select="../../@operation" />;<xsl:value-of select="../@name" />;;;<xsl:value-of select="a:dn" disable-output-escaping="yes" /><xsl:text>&#10;</xsl:text>
</xsl:when>
<xsl:when test = "@operation='add'">
<xsl:value-of select="$starttime" />;<xsl:value-of select="$maname" />;<xsl:value-of select="../../@dn" disable-output-escaping="yes" />;<xsl:value-of select="../../@operation" />;<xsl:value-of select="../@name" />;;<xsl:value-of select="a:dn" disable-output-escaping="yes" />;
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$starttime" />;<xsl:value-of select="$maname" />;<xsl:value-of select="../../@dn" disable-output-escaping="yes" />;<xsl:value-of select="../../@operation" />;<xsl:value-of select="../@name" />;;<xsl:value-of select="a:dn" disable-output-escaping="yes" />;
</xsl:otherwise>
</xsl:choose>
</xsl:for-each>
</xsl:if>

<!-- Single-valued -->
<xsl:if test = "@multivalued='false'">
<xsl:for-each select="a:dn-value">
<xsl:choose>
<xsl:when test = "@operation='delete'">
<xsl:value-of select="$starttime" />;<xsl:value-of select="$maname" />;<xsl:value-of select="../../@dn" disable-output-escaping="yes" />;<xsl:value-of select="../../@operation" />;<xsl:value-of select="../@name" />;;;<xsl:value-of select="a:dn" disable-output-escaping="yes" /><xsl:text>&#10;</xsl:text>
</xsl:when>
<xsl:when test = "@operation='add'">
<xsl:value-of select="$starttime" />;<xsl:value-of select="$maname" />;<xsl:value-of select="../../@dn" disable-output-escaping="yes" />;<xsl:value-of select="../../@operation" />;<xsl:value-of select="../@name" />;;<xsl:value-of select="a:dn" disable-output-escaping="yes" />;
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$starttime" />;<xsl:value-of select="$maname" />;<xsl:value-of select="../../@dn" disable-output-escaping="yes" />;<xsl:value-of select="../../@operation" />;<xsl:value-of select="../@name" />;;<xsl:value-of select="a:dn" disable-output-escaping="yes" />;
</xsl:otherwise>
</xsl:choose>
</xsl:for-each>
</xsl:if>

</xsl:for-each>

<!-- Non-reference attributes -->
<xsl:for-each select="a:attr">

<!-- Multi-value -->
<xsl:if test = "@multivalued='true'">
<xsl:for-each select="a:value">
<xsl:choose>
<xsl:when test = "@operation='delete'">
<xsl:value-of select="$starttime" />;<xsl:value-of select="$maname" />;<xsl:value-of select="../../@dn" disable-output-escaping="yes" />;<xsl:value-of select="../../@operation" />;<xsl:value-of select="../@name" />;;;<xsl:call-template name="handleCRLF"><xsl:with-param name="val" select="."/></xsl:call-template><xsl:text>&#10;</xsl:text>
</xsl:when>
<xsl:when test = "@operation='add'">
<xsl:value-of select="$starttime" />;<xsl:value-of select="$maname" />;<xsl:value-of select="../../@dn" disable-output-escaping="yes" />;<xsl:value-of select="../../@operation" />;<xsl:value-of select="../@name" />;;<xsl:call-template name="handleCRLF"><xsl:with-param name="val" select="."/></xsl:call-template>;
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$starttime" />;<xsl:value-of select="$maname" />;<xsl:value-of select="../../@dn" disable-output-escaping="yes" />;<xsl:value-of select="../../@operation" />;<xsl:value-of select="../@name" />;;<xsl:call-template name="handleCRLF"><xsl:with-param name="val" select="."/></xsl:call-template>;
</xsl:otherwise>
</xsl:choose>
</xsl:for-each>
</xsl:if>

<!-- Single-valued -->
<xsl:if test = "@multivalued='false'">
<xsl:if test = "@name!='unicodePwd'">
<xsl:if test = "@name!='msExchMailboxSecurityDescriptor'">
<xsl:for-each select="a:value">
<xsl:choose>
<xsl:when test = "@operation='delete'">
<xsl:value-of select="$starttime" />;<xsl:value-of select="$maname" />;<xsl:value-of select="../../@dn" disable-output-escaping="yes" />;<xsl:value-of select="../../@operation" />;<xsl:value-of select="../@name" />;;;<xsl:call-template name="handleCRLF"><xsl:with-param name="val" select="."/></xsl:call-template><xsl:text>&#10;</xsl:text>
</xsl:when>
<xsl:when test = "@operation='add'">
<xsl:value-of select="$starttime" />;<xsl:value-of select="$maname" />;<xsl:value-of select="../../@dn" disable-output-escaping="yes" />;<xsl:value-of select="../../@operation" />;<xsl:value-of select="../@name" />;;<xsl:call-template name="handleCRLF"><xsl:with-param name="val" select="."/></xsl:call-template>;
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$starttime" />;<xsl:value-of select="$maname" />;<xsl:value-of select="../../@dn" disable-output-escaping="yes" />;<xsl:value-of select="../../@operation" />;<xsl:value-of select="../@name" />;;<xsl:call-template name="handleCRLF"><xsl:with-param name="val" select="."/></xsl:call-template>;
</xsl:otherwise>
</xsl:choose>
</xsl:for-each>
</xsl:if>
</xsl:if>
</xsl:if>

</xsl:for-each>

</xsl:otherwise>
</xsl:choose>
</xsl:for-each>

</xsl:template>

<!-- Remove carriage returns inside attribute values -->
<xsl:template name="handleCRLF">
<xsl:param name="val"/>
<xsl:choose>
  <xsl:when test="contains($val,'&#10;')">
	<xsl:value-of select="substring-before($val,'&#10;')" disable-output-escaping="yes"/>
	<xsl:text> </xsl:text>
	<xsl:call-template name="handleCRLF">
	  <xsl:with-param name="val" select="substring-after($val,'&#10;')"/>
	</xsl:call-template>
  </xsl:when>
  <xsl:otherwise>
	<xsl:value-of select="$val" disable-output-escaping="yes" />
  </xsl:otherwise>
</xsl:choose>
</xsl:template>
  
</xsl:stylesheet>