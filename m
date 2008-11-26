From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/5] ftrace: use code patching for ftrace graph tracer
Date: Wed, 26 Nov 2008 00:35:53 -0800
Message-ID: <20081126003553.12d38150.akpm@linux-foundation.org>
References: <20081126051622.134970943@goodmis.org>
	<20081126051709.774546196@goodmis.org>
	<20081125213546.ff4eddf4.akpm@linux-foundation.org>
	<1227682349.5511.47.camel@brick>
	<20081126000430.5c19e189.akpm@linux-foundation.org>
	<1227688024.5511.56.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753715AbYKZIhB@vger.kernel.org>
In-Reply-To: <1227688024.5511.56.camel@brick>
Sender: linux-kernel-owner@vger.kernel.org
To: Harvey Harrison <harvey.harrison@gmail.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Frederic Weisbecker <fweisbec@gmail.com>, containers@lists.osdl.org, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Steven Rostedt <srostedt@redhat.com>
List-Id: containers.vger.kernel.org

On Wed, 26 Nov 2008 00:27:04 -0800 Harvey Harrison <harvey.harrison@gmail.com> wrote:

> if (code[0] != 0xe9 || old_offset != load32_noalign(&code[1]))
> 
> This is similar to the new API in -mm load_le32_noalign, but I
> don't think it would be worth load_u32_noalign...load32 should
> be enough.
> 
> > > > > +		return -EINVAL;
> > > > > +
> > > > > +	*(int *)(&code[1]) = new_offset;
> > > > 
> > > > Might be able to use put_unaligned_foo() here.
> > > > 
> > > 
> > > 	put_unaligned(new_offset, (int *)(&code[1]));
> > > 
> 
> In a similar vein to above, this becomes:
> 
> 	store32_noalign(&code[1], new_offset);
> 

yes, that's much better than the party tricks with magical sizeof,
which forces you to run around and check the types of everything.

I've seen people doing get_user() on `long' types and such things
occasionally.
