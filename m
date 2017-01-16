From: Oleg Drokin <green-SOTZviwpzew/JUsKyNonYw@public.gmane.org>
Subject: Re: [Lsf-pc] [LSF/MM ATTEND] FS jitter testing, network caching,
	Lustre, cluster filesystems.
Date: Mon, 16 Jan 2017 13:02:41 -0500
Message-ID: <F7FABA22-8B7D-4C77-A360-4454A5571C8F__3227.75248573652$1484589783$gmane$org@linuxhacker.ru>
References: <D863EDBD-277B-4CC3-854F-D57FF4501542@linuxhacker.ru>
	<1484587952.2540.42.camel@HansenPartnership.com>
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1484587952.2540.42.camel-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Cc: linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lsf-pc-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org


On Jan 16, 2017, at 12:32 PM, James Bottomley wrote:

> On Sun, 2017-01-15 at 18:38 -0500, Oleg Drokin wrote:
>>   A container support from filesystems is also very relevant to us 
>> since Lustre    is used more and more in such settings.
> 
> I've added the containers ML to the cc just in case.  Can you add more
> colour to this, please?  What container support for filesystems do you
> think we need beyond the user namespace in the superblock?

Namespace access is necessary, we might need it before the superblock is there
too (say during mount we might need kerberos credentials fetched to
properly authenticate this mount instance to the server).

Separately, I know that e.g. NFS tries to match underlying mounts to share
them "under the hood", so there might be a single superblock used with
several namespaces potentially, I imagine.
In Lustre it might be beneficial to do something like this too in order to conserve
resources and potentially have better fs cache sharing.
I fact the whole caching thing is somewhat complicated with memory groups too,
and if we allow shared caching between several containers, would become even more complicated.

I am sure there's a bunch of pitfalls there too that we are not realizing yet that
other people have already encountered and it would be useful to find about them.
