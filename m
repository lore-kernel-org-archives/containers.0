From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [C/R v20][PATCH 38/96] c/r: dump open file descriptors
Date: Sun, 21 Mar 2010 21:58:44 +0100
Message-ID: <4BA68884.3080003__14169.9072825306$1269205279$gmane$org@free.fr>
References: <1268960401-16680-1-git-send-email-orenl@cs.columbia.edu>	<1268960401-16680-4-git-send-email-orenl@cs.columbia.edu>	<F18D161D-850B-4C82-83D5-1F19D573E84F@sun.com>	<20100320044310.GC2887@count0.beaverton.ibm.com>	<20100321172703.GC4174@shareable.org>
	<20100321194019.GA11714@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100321194019.GA11714-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Jamie Lokier <jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org>, Andreas Dilger <adilger-xsfywfwIY+M@public.gmane.org>
List-Id: containers.vger.kernel.org

Serge E. Hallyn wrote:
> Quoting Jamie Lokier (jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org):
>   
>> Matt Helsley wrote:
>>     
>>>> That said, if the intent is to allow the restore to be done on
>>>> another node with a "similar" filesystem (e.g. created by rsync/node
>>>> image), instead of having a coherent distributed filesystem on all
>>>> of the nodes then the filename makes sense.
>>>>         
>>> Yes, this is the intent.
>>>       
>> I would worry about programs which are using files which have been
>> deleted, renamed, or (very common) renamed-over by another process
>> after being opened, as there's a good chance they will successfully
>> open the wrong file after c/r, and corrupt state from then on.
>>     
>
> Userspace is expected to back up and restore the filesystem, for
> instance using a btrfs snapshot or a simple rsync or tar.
>
>   
That does not solve the problem Jamie is talking about.
A rsync or a tar will not see a deleted file and using a btrfs to have 
the CR to work with the deleted files is a bit overkill, no ?
I have another question about the deleted files. How is handled the case 
when a process has a deleted mapped file but without an associated file 
descriptor ?

> If we detect anything which really is not supported (for instance
> inotify for now) then we fail and leave a log message explaining the
> failure.
>   
