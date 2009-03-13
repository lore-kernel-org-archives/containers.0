From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v13][PATCH 00/14] Kernel based checkpoint/restart
Date: Thu, 12 Mar 2009 23:57:45 -0400
Message-ID: <49B9D9B9.4070508__25556.1025151566$1236916938$gmane$org@cs.columbia.edu>
References: <1233076092-8660-1-git-send-email-orenl@cs.columbia.edu>	<1234285547.30155.6.camel@nimitz>	<20090211141434.dfa1d079.akpm@linux-foundation.org>	<1234462282.30155.171.camel@nimitz>	<20090213152836.0fbbfa7d.akpm@linux-foundation.org>
	<49B9C8E0.5080500@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49B9C8E0.5080500-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org
List-Id: containers.vger.kernel.org



Oren Laadan wrote:
> Hi,
> 
> Just got back from 3 weeks with practically no internet, and I see
> that I missed a big party !
> 
> Trying to catch up with what's been said so far --

[...]

>>>>
>>>> - Will any of this involve non-trivial serialisation of kernel
>>>>   objects?  If so, that's getting into the
>>>>   unacceptably-expensive-to-maintain space, I suspect.
>>> We have some structures that are certainly tied to the kernel-internal
>>> ones.  However, we are certainly *not* simply writing kernel structures
>>> to userspace.  We could do that with /dev/mem.  We are carefully pulling
>>> out the minimal bits of information from the kernel structures that we
>>> *need* to recreate the function of the structure at restart.  There is a
>>> maintenance burden here but, so far, that burden is almost entirely in
>>> checkpoint/*.c.  We intend to test this functionality thoroughly to
>>> ensure that we don't regress once we have integrated it.
>> I guess my question can be approximately simplified to: "will it end up
>> looking like openvz"?  (I don't believe that we know of any other way
>> of implementing this?)
>>
>> Because if it does then that's a concern, because my assessment when I
>> looked at that code (a number of years ago) was that having code of
>> that nature in mainline would be pretty costly to us, and rather
>> unwelcome.
> 
> I originally implemented c/r for linux as as kernel module, without
> requiring any changes from the kernel. (Doing the namespaces as a kernel
> module was much harder). For more details, see:
> 	https://www.ncl.cs.columbia.edu/research/migrate

oops... I meant the following link:
	http://www.ncl.cs.columbia.edu/research/migration/

see, for example, the papers from DejaView (SOSP 07) and Zap (USENIX 07).

Oren.
