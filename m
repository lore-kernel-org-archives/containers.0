From: dlezcano@fr.ibm.com
Subject: [net-2.6.24][patch 0/2] Dynamically allocate the loopback
Date: Mon, 17 Sep 2007 15:45:09 +0200
Message-ID: <20070917134509.222896190@mai.toulouse-stg.fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
To: davem@davemloft.net
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

This patch allows to dynamically allocate the loopback
like an usual network device.

This global static variable loopback_dev has been replaced by a
netdev pointer and the init function does the usual allocation,
initialization and registering of the loopback.

This patchset is splitted in two parts, the first one is a big but
trivial patch which replace the usage of the static variable loopback_dev
by the usage of a pointer. The second patch is the interesting part where
the loopback is dynamically allocated.

-- 
