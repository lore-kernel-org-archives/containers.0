From: Dave Hansen <dave@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/3] s390: Expose a constant for the number of words
	representing the CRs
Date: Tue, 03 Mar 2009 08:08:14 -0800
Message-ID: <1236096494.22399.5.camel@nimitz>
References: <1236095764-19325-1-git-send-email-danms@us.ibm.com>
	 <1236095764-19325-2-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756684AbZCDAcj@vger.kernel.org>
In-Reply-To: <1236095764-19325-2-git-send-email-danms@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Cc: containers@lists.osdl.org, linux-s390@vger.kernel.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

On Tue, 2009-03-03 at 10:56 -0500, Dan Smith wrote:
> We need to use this value in the checkpoint/restart code and would like to
> have a constant instead of a magic '3'.

This doesn't do a lot of good unless it gets used in the base s390 code.
Otherwise, why not just define it near its use in the c/r code?

-- Dave
