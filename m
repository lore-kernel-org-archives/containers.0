From: Dave Hansen <haveblue@us.ibm.com>
Subject: Re: Containers: css_put() dilemma
Date: Tue, 17 Jul 2007 09:02:11 -0700
Message-ID: <1184688131.6454.109.camel@localhost>
References: <469BBE00.8000709@linux.vnet.ibm.com>
	 <6599ad830707161203o7f148c75p52e77d4be3ace487@mail.gmail.com>
	 <469C2792.6050009@linux.vnet.ibm.com>
	 <6599ad830707161935n69776f1t98292fc9990f4766@mail.gmail.com>
	 <20070717070031.GA22410@linux.vnet.ibm.com>
	 <6599ad830707170018p180cb7dfr53e609fd0b186e30@mail.gmail.com>
	 <469C99D1.7090807@linux.vnet.ibm.com>
	 <6599ad830707170849v11fe8cecs6d172cd38d247e09@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934502AbXGQQC2@vger.kernel.org>
In-Reply-To: <6599ad830707170849v11fe8cecs6d172cd38d247e09@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Paul =?UTF-8?Q?=28=E5=AE=9D=E7=91=A0=29?= Menage <menage@google.com>
Cc: balbir@linux.vnet.ibm.com, dhaval@linux.vnet.ibm.com, linux kernel mailing list <linux-kernel@vger.kernel.org>, Pavel Emelianov <xemul@sw.ru>, Paul Jackson <pj@sgi.com>, Linux Containers <containers@lists.osdl.org>, Andrew Morton <akpm@linux-foundation.org>
List-Id: containers.vger.kernel.org

On Tue, 2007-07-17 at 08:49 -0700, Paul (=E5=AE=9D=E7=91=A0) Menage wro=
te:
> Because as soon as you do the atomic_dec_and_test() on css->refcnt an=
d
> the refcnt hits zero, then theoretically someone other thread (that
> already holds container_mutex) could check that the refcount is zero
> and free the container structure.

Then that other task had a reference and itself should have bumped the
count, and the other user would never have seen it hit zero.

Even if there are still pages attached to the container, why not just
have those take a reference, and don't bother actually freeing the
container until the last true reference is dropped?

Does it matter if the destruction callbacks don't happen until well
after an attempt to destroy the container is made?

-- Dave
