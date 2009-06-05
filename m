From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 4/4] Conditionally force on namespaces
Date: Fri, 05 Jun 2009 16:21:02 -0500
Message-ID: <m24ouufkch.fsf@pobox.com>
References: <20090605191525.C3F1C2F2@kernel> <20090605191530.04562DD1@kernel>
	<20090605193538.GA22848@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090605193538.GA22848-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Serge E. Hallyn's message
	of "Fri\, 5 Jun 2009 14\:35\:38 -0500")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:
> Quoting Dave Hansen (dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
>> 
>> This should work around the compile issues that Nathan
>> pointed out yesterday.  It's too bad that 'select' is
>> such a blunt object.  We could surely use a soft select
>> or something.  But this hacks around it a bit.
>> 
>> Create a separate "*_NS_DEP" Kconfig option for the
>> dependencies for each namespace.  Make the real config
>> option and the c/r 'select' bot dependent on the new
>> common one.
>> 
>> This should at least keep compile errors from being
>> introduced.  Whether this is rude or not is a separate
>> questions. :)
>
> Yeah I'm not sure I'm a fan of this...
>
> While I hate chasing down missing dependencies, maybe
> CONFIG_CHECKPOINT should just depend on all the namespaces
> instead of selecting them?
>
> I'd assumed that was Nathan was really asking for, though
> I could be wrong.

I was mainly interested in preventing build breaks.  :)

While Oren's checkpoint implementation is useful with any combination of
the *_NS config options, ensuring that the kernel builds and functions
correctly with all the permutations looks non-trivial.  Making
CHECKPOINT depend on all the *_NS options looks like an easy way to
avoid the mess.  Dave's patches seem to provide the maximum amount of
flexibility, but my suspicion is that most interested parties tend to
turn on all of *_NS anyway (as distros are starting to do), and that
other configurations (e.g. CHECKPOINT=y, NET_NS=n) simply won't get
test coverage in practice.
