From: "=?ISO-2022-JP?B?UGF1bCAoGyRCSnVOXBsoQikgTWVuYWdl?="
	<menage@google.com>
Subject: Re: Containers: css_put() dilemma
Date: Tue, 17 Jul 2007 00:18:33 -0700
Message-ID: <6599ad830707170018p180cb7dfr53e609fd0b186e30@mail.gmail.com>
References: <469BBE00.8000709@linux.vnet.ibm.com>
	 <6599ad830707161203o7f148c75p52e77d4be3ace487@mail.gmail.com>
	 <469C2792.6050009@linux.vnet.ibm.com>
	 <6599ad830707161935n69776f1t98292fc9990f4766@mail.gmail.com>
	 <20070717070031.GA22410@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1765939AbXGQHS4@vger.kernel.org>
In-Reply-To: <20070717070031.GA22410@linux.vnet.ibm.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: balbir@linux.vnet.ibm.com
Cc: Pavel Emelianov <xemul@sw.ru>, linux kernel mailing list <linux-kernel@vger.kernel.org>, Paul Jackson <pj@sgi.com>, Linux Containers <containers@lists.osdl.org>, Andrew Morton <akpm@linux-foundation.org>, dhaval@linux.vnet.ibm.com
List-Id: containers.vger.kernel.org

On 7/17/07, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> >
> > >                mutex_lock(&container_mutex);
> > >                set_bit(CONT_RELEASABLE, &cont->flags);
> > >-               if (atomic_dec_and_test(&css->refcnt)) {
> > >-                       check_for_release(cont);
> > >-               }
> > >+               check_for_release(cont);
> > >                mutex_unlock(&container_mutex);
> > >

I think that this isn't safe as it stands, without a synchronize_rcu()
in container_diput() prior to the kfree(). Also, it will break if
anyone tries to use a release agent on a hierarchy that has your
memory controller bound to it.

Paul
