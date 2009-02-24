From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/4] mqueue namespace: adapt sysctl
Date: Tue, 24 Feb 2009 14:48:00 -0800
Message-ID: <20090224144800.4c7e3fcb.akpm@linux-foundation.org>
References: <20090224220256.GA31001@us.ibm.com>
	<20090224141651.70155ebd.akpm@linux-foundation.org>
	<20090224223245.GA17473@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760946AbZBXWsq@vger.kernel.org>
In-Reply-To: <20090224223245.GA17473@x200.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: serue@us.ibm.com, clg@fr.ibm.com, linux-kernel@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

On Wed, 25 Feb 2009 01:32:45 +0300
Alexey Dobriyan <adobriyan@gmail.com> wrote:

> > > +proc_handler *proc_mq_dointvec = NULL;
> > > +proc_handler *proc_mq_dointvec_minmax = NULL;
> > > +#endif
> > 
> > looks odd.  Was this
> > 
> > --- a/ipc/mq_sysctl.c~mqueue-namespace-adapt-sysctl-update-fix
> > +++ a/ipc/mq_sysctl.c
> > @@ -52,8 +52,8 @@ static int proc_mq_dointvec_minmax(ctl_t
> >  					lenp, ppos);
> >  }
> >  #else
> > -proc_handler *proc_mq_dointvec = NULL;
> > -proc_handler *proc_mq_dointvec_minmax = NULL;
> > +#define proc_mq_dointvec NULL
> > +#define proc_mq_dointvec_minmax NULL
> >  #endif
> 
> I hope, not.
> 
> "#define foo NULL" is the least intrusive thing.

well the original code would have spat a warning at compile time
then tried to execute code from BSS at runtime, methinks.

But I can't be assed working out how to disable CONFIG_SYSCTL to
test that.  Gawd I hate `select'.
