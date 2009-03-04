From: Dan Smith <danms@us.ibm.com>
Subject: Re: [PATCH 1/3] s390: Expose a constant for the number of words representing the CRs
Date: Tue, 03 Mar 2009 16:56:03 -0800
Message-ID: <87d4cyrtr0.fsf@caffeine.danplanet.com>
References: <1236095764-19325-1-git-send-email-danms@us.ibm.com>
	<1236095764-19325-2-git-send-email-danms@us.ibm.com>
	<1236096494.22399.5.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756295AbZCDA4X@vger.kernel.org>
In-Reply-To: <1236096494.22399.5.camel@nimitz> (Dave Hansen's message of "Tue,
	03 Mar 2009 08:08:14 -0800")
Sender: linux-kernel-owner@vger.kernel.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: containers@lists.osdl.org, linux-s390@vger.kernel.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

DH> This doesn't do a lot of good unless it gets used in the base s390
DH> code.  Otherwise, why not just define it near its use in the c/r
DH> code?

I intended to replace all uses, but I just found one place I missed,
but I think that's it.  If you know of other places that it's used in
the s390 code, other than in compat_ptrace.h and ptrace.h please point
them out.

-- 
Dan Smith
IBM Linux Technology Center
email: danms@us.ibm.com
