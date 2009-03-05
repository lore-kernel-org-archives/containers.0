From: Dan Smith <danms@us.ibm.com>
Subject: Re: [PATCH 1/1] checkpoint: define pid==0 as self-checkpoint
Date: Thu, 05 Mar 2009 10:23:24 -0800
Message-ID: <87hc27vnfn.fsf@caffeine.danplanet.com>
References: <20090305174951.GA9782@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756579AbZCESXi@vger.kernel.org>
In-Reply-To: <20090305174951.GA9782@us.ibm.com> (Serge E. Hallyn's message of
	"Thu, 5 Mar 2009 11:49:51 -0600")
Sender: linux-kernel-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Oren Laadan <orenl@cs.columbia.edu>, Dave Hansen <haveblue@us.ibm.com>, Linux Containers <containers@lists.osdl.org>, lkml <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org

SH> Define pid=0 when calling sys_checkpoint as asking for a
SH> self-checkpoint.

Works for me (of course).

-- 
Dan Smith
IBM Linux Technology Center
email: danms@us.ibm.com
