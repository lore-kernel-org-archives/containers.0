From: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH v2] /proc/pid/status: show all sets of pid according to ns
Date: Wed, 28 May 2014 23:27:05 +0400
Message-ID: <53863889.9080509__24763.4055828259$1401305273$gmane$org@parallels.com>
References: <1401272683-1659-1-git-send-email-chenhanxiao@cn.fujitsu.com>
	<5385DA19.2060008@parallels.com> <20140528182824.GA5057@cachalot>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140528182824.GA5057@cachalot>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vasily Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
Cc: Richard Weinberger <richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

On 05/28/2014 10:28 PM, Vasily Kulikov wrote:
> On Wed, May 28, 2014 at 16:44 +0400, Pavel Emelyanov wrote:
>> On 05/28/2014 02:24 PM, Chen Hanxiao wrote:
>>> We need a direct method of getting the pid inside containers.
>>
>> But there's more generic issue -- some day we'll need to know not only
>> PIDs as seen from different namespaces, but also SIDs and PGIDs.
> 
> Maybe include all per-ns ID in a separate file?

This looks reasonable, but wouldn't this file be too big for a loaded system?

> Then the old 'status'
> file includes IDs from the current namespace only, the new file (e.g.
> 'ids' or 'ns_ids') contains only hierarchical IDs which differ from
> namespace to namespace for all possible namespaces.  

For all visible namespaces. I.e. -- if a task lives in a container and reads
its /proc/self/status it should _not_ see its host pid. Just like it is now
in the current patch. Otherwise it would bring blockers to live migration :(

> It will be simplier
> to parse the file -- if 'ns_ids' file contains some ID then this ID for
> every ns can be obtained regardless of the specific ID name (SID, PID,
> PGID, etc.).

True, but given a task PID how to determine which pid namespaces it lives in
to get the idea of how PIDs map to each other? Maybe we need some explicit
API for converting (ID, NS1, NS2) into (ID)?

Thanks,
Pavel
