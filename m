From: Dhaval Giani <dhaval@linux.vnet.ibm.com>
Subject: Re: A question about group CFS scheduling
Date: Thu, 26 Jun 2008 15:13:20 +0530
Message-ID: <20080626094320.GA5326@linux.vnet.ibm.com>
References: <ac8af0be0806260019q45fa7285oa0fc79fb02254d28@mail.gmail.com> <1214468112.2794.9.camel@twins.programming.kicks-ass.net> <ac8af0be0806260133u68a5692flab65e4bb6dcf2a13@mail.gmail.com>
Reply-To: Dhaval Giani <dhaval@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757923AbYFZJoU@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <ac8af0be0806260133u68a5692flab65e4bb6dcf2a13@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Zhao Forrest <forrest.zhao@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>, containers@lists.osdl.org, mingo@elte.hu, vatsa@linux.vnet.ibm.com, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

On Thu, Jun 26, 2008 at 04:33:11PM +0800, Zhao Forrest wrote:
> 
> Thank you for your detailed explanation! I have one more question:
> cgrouping and USER grouping is mutual exclusive, am I right? That is,
> when enabling cgrouping, USER grouping need to be disabled, vice
> versa.
> 

Yes, you are right.

-- 
regards,
Dhaval
