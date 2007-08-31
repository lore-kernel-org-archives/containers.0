From: "Balbir Singh" <balbir@linux.vnet.ibm.com>
Subject: Re: [-mm PATCH] Memory controller improve user interface (v2)
Date: Sat, 1 Sep 2007 03:24:45 +0530
Message-ID: <661de9470708311454l3aaea0d3g4555721ba84c8aba@mail.gmail.com>
References: <20070830185246.3170.74806.sendpatchset@balbir-laptop>
	 <20070831130216.226db806.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756821AbXHaVy5@vger.kernel.org>
In-Reply-To: <20070831130216.226db806.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux@smtp2.linux-foundation.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM Mailing List <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Containers <containers@lists.osdl.org>, Paul Menage <menage@google.com>
List-Id: containers.vger.kernel.org

On 9/1/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Fri, 31 Aug 2007 00:22:46 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>
> > +/*
> > + * Strategy routines for formating read/write data
> > + */
> > +int mem_container_read_strategy(unsigned long long val, char *buf)
> > +{
> > +     return sprintf(buf, "%llu Bytes\n", val);
> > +}
>
> It's a bit cheesy to be printing the units like this.  It's better to just
> print the raw number.
>
> If you really want to remind the user what units that number is in (not a
> bad idea) then it can be encoded in the filename, like
> /proc/sys/vm/min_free_kbytes, /proc/sys/vm/dirty_expire_centisecs, etc.
>

Sounds good, I'll change the file to memory.limit_in_bytes and
memory.usage_in_bytes.

>
> > +int mem_container_write_strategy(char *buf, unsigned long long *tmp)
> > +{
> > +     *tmp = memparse(buf, &buf);
> > +     if (*buf != '\0')
> > +             return -EINVAL;
> > +
> > +     printk("tmp is %llu\n", *tmp);
>
> don't think we want that.
>

Yes, I'll redo the patch and resend.

> > +     /*
> > +      * Round up the value to the closest page size
> > +      */
> > +     *tmp = ((*tmp + PAGE_SIZE - 1) >> PAGE_SHIFT) << PAGE_SHIFT;
> > +     return 0;
> > +}

Thanks,
Balbir
