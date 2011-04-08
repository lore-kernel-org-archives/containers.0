From: Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH 1/3] Add network context to struct nfs_client and make
	NFSv3 use it.
Date: Fri, 8 Apr 2011 08:29:29 -0500
Message-ID: <4D9F0DB9.9040202__31589.3814935864$1302269515$gmane$org@parallels.com>
References: <4D94318A.5050202@parallels.com> <20110405025228.GA6764@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110405025228.GA6764-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
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
Cc: Kir Kolyshkin <kir-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Tim Spriggs <tims-DAzCR1AAk2Rg9hUCZPvPmw@public.gmane.org>, Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 04/04/2011 09:52 PM, Serge E. Hallyn wrote:
> Quoting Rob Landley (rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org):
>> From: Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
>>
>> This patch:
>>
>>   Adds struct net *cl_net to struct nfs_client.
>>   Intializes it from mount process context.
>>   Copies it down through nfs_client_initdata and similar.
>>   Replaces existing init_net uses with cl_net.
>>   Adds net_eq() checks to nfs_match_client() and nfs_compare_super_address().
>>
>> Remount copies the existing network context rather than any associated with
>> the new mount process.  NFSv4 is still using init_net.  Reference counting
>> for struct net follows the struct nfs_client object lifetimes (pinned by
>> task context outside of that).
>>
>> Signed-off-by: Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> 
> Sorry for the delay.  Took me two long readings to feel like I've got
> it.
> 
> Acked-by: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
> 
> Do you have any testcases coded up for this?

Not coded up, just stuff I ran from the command line, as described in
the 0/3 patch:

  http://www.spinics.net/lists/linux-nfs/msg20307.html

Here's a blog entry describing the two different types of test cases in
more detail:

  http://landley.livejournal.com/55534.html

The "occlusion" test case (which can only reach an IP address from one
network context because a local interface intercepts it otherwise, and
prevents it from routing out) works fine, and filtering at the NFS
server (giving different source IP addresses different NFS flags, such
as making it read only for one and read/write for another) worked fine
for me too.

The "redirection" test case (where the same IP address routes out from
both contexts, but reaches different destinations) seems to screw up the
Linux arp cache or something, so that the _host_ can no longer access
that address for a bit once the container has done so (and vice versa).
 But that doesn't seem to be an NFS-specific issue, or a new bug I
introduced.  (I'm still working on that one, it's obscure, reproducible,
and confusing.  But these patches don't make it worse, so...)

Rob
