package com.spcms.stability;

import org.junit.jupiter.api.condition.EnabledIfSystemProperty;

@EnabledIfSystemProperty(named = "spcms.mysql.tests", matches = "true")
class CoreFlowMySqlProfileTest extends AbstractCoreFlowProfileTest {
}

