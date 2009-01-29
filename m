From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: [RFC][PATCH 0/5] Simplify devpts code
Date: Wed, 28 Jan 2009 22:42:59 -0800
Message-ID: <20090129064259.GA23160@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757118AbZA2GrU@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Christoph Hellwig <hch@lst.de>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, hpa@zytor.com, serue@us.ibm.com, "David C. Hansen" <haveblue@us.ibm.com>, Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org, sukadev@us.ibm.com
List-Id: containers.vger.kernel.org


This patchset tries to address Christoph Hellwig's review comments on the
support for multiple-instances in devpts.  http://lkml.org/lkml/2009/1/3/84
It breaks up the patch into smaller pieces for (hopefully)  easier review.

IIUC, the key observation was that most of do_remount_sb() (MS_RDONLY flag
and shrink_dcache() does not apply to devpts and only the parsing of
options does. Moving the parsing code into devpts enables us to parse
the options just once and vastly simplifies the code.

This patchset does not change any functionality/behavior. But it does
depend on following two related patches.

	http://lkml.org/lkml/2009/1/29/10
	http://lkml.org/lkml/2009/1/29/11

Patches in this set:

	[PATCH 1/5] Unroll essentials of do_remount_sb() into devpts
	[PATCH 2/5] Parse mount options just once and copy them to super block
	[PATCH 3/5] Move common mknod_ptmx() calls into caller
	[PATCH 4/5] Remove get_init_pts_sb()
	[PATCH 5/5] Merge code for single and multiple-instance mounts

Touch tested. Bisect safe. Needs more testing.

TODO: (possibly as a separate patch ?)
	- Merge CONFIG_DEVPTS_MULTIPLE_INSTANCES token with other container-
	  related tokens ? 
