From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] Enhance checkpoint/restart Kconfig options
Date: Thu, 04 Jun 2009 21:32:17 -0400
Message-ID: <4A2875A1.8080009@cs.columbia.edu>
References: <20090604184504.F1BCB2F8@kernel> <m3iqjbix8u.fsf@pobox.com>
	<1244146621.20418.4912.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1244146621.20418.4912.camel@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org



Dave Hansen wrote:
> On Thu, 2009-06-04 at 15:01 -0500, Nathan Lynch wrote:
>> Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> writes:
>>> diff -puN checkpoint/Kconfig~cr-kconfig-fixup checkpoint/Kconfig
>>> --- linux-2.6.git/checkpoint/Kconfig~cr-kconfig-fixup	2009-06-04 11:38:57.000000000 -0700
>>> +++ linux-2.6.git-dave/checkpoint/Kconfig	2009-06-04 11:38:57.000000000 -0700
>>> @@ -7,9 +7,14 @@ config DEFERQUEUE
>>>  	default n
>>>  
>>>  config CHECKPOINT
>>> -	bool "Enable checkpoint/restart (EXPERIMENTAL)"
>>> +	bool "Checkpoint/restart (EXPERIMENTAL)"
>>>  	depends on CHECKPOINT_SUPPORT && EXPERIMENTAL
>>>  	select DEFERQUEUE
>>> +	select UTS_NS
>>> +	select IPC_NS
>>> +	select NET_NS
>>> +	select PID_NS
>>> +	select USER_NS
>> *_NS all depend on NAMESPACES at the very least; some have additional
>> dependencies.  Selecting a symbol without ensuring its dependencies are
>> enabled is one way to break a build.
> 
> Ahh, but there *isn't* a strict build dependency on them.  We just want
> to make sure that if they're available that we enable them.  If we have
> CONFIG_NET=n, then we certainly don't want to make CHECKPOINT depends on
> it.  
> 
>> Also - checkpoint is useful without *_NS, no?  Forcing these things on
>> seems a little user-hostile..

I concur.

> 
> I think the hostile thing is trying to completely unshare all the
> namespaces without checking to see which ones are enabled, first. ;)

I concur again :o

Will fix that.

Oren.
