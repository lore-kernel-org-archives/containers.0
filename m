From: "=?ISO-2022-JP?B?UGF1bCAoGyRCSnVOXBsoQikgTWVuYWdl?="
	<menage@google.com>
Subject: Re: Containers: css_put() dilemma
Date: Tue, 17 Jul 2007 08:49:51 -0700
Message-ID: <6599ad830707170849v11fe8cecs6d172cd38d247e09@mail.gmail.com>
References: <469BBE00.8000709@linux.vnet.ibm.com>
	 <6599ad830707161203o7f148c75p52e77d4be3ace487@mail.gmail.com>
	 <469C2792.6050009@linux.vnet.ibm.com>
	 <6599ad830707161935n69776f1t98292fc9990f4766@mail.gmail.com>
	 <20070717070031.GA22410@linux.vnet.ibm.com>
	 <6599ad830707170018p180cb7dfr53e609fd0b186e30@mail.gmail.com>
	 <469C99D1.7090807@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S935378AbXGQPue@vger.kernel.org>
In-Reply-To: <469C99D1.7090807@linux.vnet.ibm.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: balbir@linux.vnet.ibm.com
Cc: dhaval@linux.vnet.ibm.com, Pavel Emelianov <xemul@sw.ru>, linux kernel mailing list <linux-kernel@vger.kernel.org>, Paul Jackson <pj@sgi.com>, Linux Containers <containers@lists.osdl.org>, Andrew Morton <akpm@linux-foundation.org>
List-Id: containers.vger.kernel.org

On 7/17/07, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> Paul (??) Menage wrote:
> > On 7/17/07, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> >> >
> >> > >                mutex_lock(&container_mutex);
> >> > >                set_bit(CONT_RELEASABLE, &cont->flags);
> >> > >-               if (atomic_dec_and_test(&css->refcnt)) {
> >> > >-                       check_for_release(cont);
> >> > >-               }
> >> > >+               check_for_release(cont);
> >> > >                mutex_unlock(&container_mutex);
> >> > >
> >
> > I think that this isn't safe as it stands, without a synchronize_rcu()
> > in container_diput() prior to the kfree(). Also, it will break if
> > anyone tries to use a release agent on a hierarchy that has your
> > memory controller bound to it.
> >
>
>
> Isn't the code functionally the same as before? We still do atomic_test_and_dec()
> as before. We still set_bit() CONT_RELEASABLE, we take the container_mutex
> and check_for_release(). I am not sure I understand what changed?

Because as soon as you do the atomic_dec_and_test() on css->refcnt and
the refcnt hits zero, then theoretically someone other thread (that
already holds container_mutex) could check that the refcount is zero
and free the container structure.

Adding a synchronize_rcu in container_diput() guarantees that the
container structure won't be freed while someone may still be
accessing it.

>
> Could you please elaborate as to why using a release agent is broken
> when the memory controller is attached to it?

Because then it will try to take container_mutex in css_put() if it
drops the last reference to a container, which is the thing that you
said you had to avoid since you called css_put() in contexts that
couldn't sleep.

Paul
