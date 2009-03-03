From: Dan Smith <danms@us.ibm.com>
Subject: [PATCH 0/3] c/r: Add s390 support
Date: Tue,  3 Mar 2009 10:56:01 -0500
Message-ID: <1236095764-19325-1-git-send-email-danms@us.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758427AbZCCP51@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: containers@lists.osdl.org
Cc: linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

This set adds checkpoint/restart support for s390.  It is to be applied on
top of Oren's ckpt-v13 set[1] and has been tested with the single and multi-
process tests in user-cr.

1: http://lkml.org/lkml/2009/1/27/227
