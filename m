From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 1/3] ftrace: graph of a single function
Date: Wed, 3 Dec 2008 16:10:38 -0500 (EST)
Message-ID: <alpine.DEB.1.10.0812031608560.29045@gandalf.stny.rr.com>
References: <20081203203656.776893226@goodmis.org> <20081203203828.920111079@goodmis.org> <20081203130741.473c1262.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756344AbYLCVLY@vger.kernel.org>
In-Reply-To: <20081203130741.473c1262.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, mingo@elte.hu, fweisbec@gmail.com, peterz@infradead.org, arjan@infradead.org, dave@linux.vnet.ibm.com, containers@lists.osdl.org, ebiederm@xmission.com, sukadev@linux.vnet.ibm.com, serue@us.ibm.com, srostedt@redhat.com
List-Id: containers.vger.kernel.org



On Wed, 3 Dec 2008, Andrew Morton wrote:

> On Wed, 03 Dec 2008 15:36:57 -0500
> Steven Rostedt <rostedt@goodmis.org> wrote:
> 
> > +static int g_show(struct seq_file *m, void *v)
> > +{
> > +	unsigned long *ptr = v;
> > +	char str[KSYM_SYMBOL_LEN];
> > +
> > +	if (!ptr)
> > +		return 0;
> > +
> > +	kallsyms_lookup(*ptr, NULL, NULL, NULL, str);
> > +
> > +	seq_printf(m, "%s\n", str);
> 
> Can we use %pF here?

If there's a way to not print the "+offset".

blk_unplug looks much nicer than blk_unplug+0x78/0x278

-- Steve
