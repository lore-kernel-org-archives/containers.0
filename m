From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: the perfomance of lxc is not better than kvm+virtio
Date: Thu, 6 Sep 2012 18:39:54 +0400
Message-ID: <5048B5BA.3070802@parallels.com>
References: <369c0ce8.7437.1399ac363cf.Coremail.dx10years@126.com>
	<DF13143A-64A8-459C-B415-B3E661611C2A@parallels.com>
	<21d457be.9cee.1399be2b299.Coremail.dx10years@126.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <21d457be.9cee.1399be2b299.Coremail.dx10years-KN7UnAbNpbg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "cmcc.dylan" <dx10years-KN7UnAbNpbg@public.gmane.org>
Cc: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Kirill Korotaev <dev-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Id: containers.vger.kernel.org

On 09/06/2012 06:01 PM, cmcc.dylan wrote:
> 
> 
>> >2. 596 and even 700MB/sec makes me think you measure not real disk I/O, but memory (cache).
> i'm also think this is a results due to cache, for example page cache in the host os. Do you have some ideas bypassing memory cache?
> 
> 
Check your kvm command line. IIRC, KVM has a fully-cached mode of
operation. Writes to guest "disk" will not actually reach the disk for a
while. While this is nice, this is an unfair comparison from a benchmark
PoV, because of you are, of course, trading away a bit of your
data-safety. It is still safe against guest power-off, but not
necessarily against host power-off. Also, since there is no magic, this
can hurt you in very dense scenarios.

The "-drive" parameter will probably have a "cache" specifier, which is
what you are looking for.
