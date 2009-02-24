From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 4/4] mqueue namespace: adapt sysctl
Date: Tue, 24 Feb 2009 17:23:03 -0600
Message-ID: <20090224232303.GA1435@us.ibm.com>
References: <20090224220256.GA31001@us.ibm.com> <20090224141651.70155ebd.akpm@linux-foundation.org> <20090224223245.GA17473@x200.localdomain> <20090224144800.4c7e3fcb.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759865AbZBXXXV@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090224144800.4c7e3fcb.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexey Dobriyan <adobriyan@gmail.com>, clg@fr.ibm.com, linux-kernel@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

Quoting Andrew Morton (akpm@linux-foundation.org):
> On Wed, 25 Feb 2009 01:32:45 +0300
> Alexey Dobriyan <adobriyan@gmail.com> wrote:
> 
> > > > +proc_handler *proc_mq_dointvec = NULL;
> > > > +proc_handler *proc_mq_dointvec_minmax = NULL;
> > > > +#endif
> > > 
> > > looks odd.  Was this
> > > 
> > > --- a/ipc/mq_sysctl.c~mqueue-namespace-adapt-sysctl-update-fix
> > > +++ a/ipc/mq_sysctl.c
> > > @@ -52,8 +52,8 @@ static int proc_mq_dointvec_minmax(ctl_t
> > >  					lenp, ppos);
> > >  }
> > >  #else
> > > -proc_handler *proc_mq_dointvec = NULL;
> > > -proc_handler *proc_mq_dointvec_minmax = NULL;
> > > +#define proc_mq_dointvec NULL
> > > +#define proc_mq_dointvec_minmax NULL
> > >  #endif
> > 
> > I hope, not.
> > 
> > "#define foo NULL" is the least intrusive thing.
> 
> well the original code would have spat a warning at compile time
> then tried to execute code from BSS at runtime, methinks.
> 
> But I can't be assed working out how to disable CONFIG_SYSCTL to
> test that.  Gawd I hate `select'.

Yeah that's a pain...  but so I tested it with the below userspace
program before sending the patch and the 'if (myhandler)' check (which
is analogous to the check in proc_sys_call_handler) worked as expected.

thanks,
-serge

#include <stdio.h>

typedef int proc_handler (int a, int b);

#ifdef FOO
int myhandler(int a, int b) {
	printf("a was %d b was %d\n", a, b);
}
#else
proc_handler *myhandler = NULL;
#endif

int main()
{
	if (myhandler)
		myhandler(1, 2);
}
