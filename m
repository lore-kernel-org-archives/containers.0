From: Oleg Drokin <green-SOTZviwpzew/JUsKyNonYw@public.gmane.org>
Subject: Re: [Lsf-pc] [LSF/MM ATTEND] FS jitter testing, network caching,
	Lustre, cluster filesystems.
Date: Tue, 17 Jan 2017 02:00:27 -0500
Message-ID: <AE738992-D640-48B1-B7C3-E4E798504F7A@linuxhacker.ru>
References: <D863EDBD-277B-4CC3-854F-D57FF4501542@linuxhacker.ru>
	<1484587952.2540.42.camel@HansenPartnership.com>
	<F7FABA22-8B7D-4C77-A360-4454A5571C8F@linuxhacker.ru>
	<1484590862.2540.51.camel@HansenPartnership.com>
	<9CA51BCE-7FF9-4212-9C43-B8B3667E7E6D@linuxhacker.ru>
	<1484600330.2540.69.camel@HansenPartnership.com>
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1484600330.2540.69.camel-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
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


On Jan 16, 2017, at 3:58 PM, James Bottomley wrote:

> On Mon, 2017-01-16 at 13:39 -0500, Oleg Drokin wrote:
>> On Jan 16, 2017, at 1:21 PM, James Bottomley wrote:
>> 
>>> On Mon, 2017-01-16 at 13:02 -0500, Oleg Drokin wrote:
>>>> On Jan 16, 2017, at 12:32 PM, James Bottomley wrote:
>>>> 
>>>>> On Sun, 2017-01-15 at 18:38 -0500, Oleg Drokin wrote:
>>>>>> A container support from filesystems is also very relevant 
>>>>>> to us since Lustre    is used more and more in such settings.
>>>>> 
>>>>> I've added the containers ML to the cc just in case.  Can you 
>>>>> add more colour to this, please?  What container support for 
>>>>> filesystems do you think we need beyond the user namespace in
>>>>> the superblock?
>>>> 
>>>> Namespace access is necessary, we might need it before the 
>>>> superblock is there too (say during mount we might need kerberos 
>>>> credentials fetched to properly authenticate this mount instance 
>>>> to the server).
>>> 
>>> The superblock namespace is mostly for uid/gid changes across the
>>> kernel <-> filesystem boundary.
>> 
>> That's on the kernel<->filesystem, but inside of the FS there might 
>> be other considerations that you might want to attach there.
>> Say when you are encrypting the traffic to the server you want
>> to use the right keys.
> 
> So this is the keyring namespace?  It was mentioned at KS, but, as far
> as I can tell, not discussed in the Containers MC that followed, so
> I've no idea what the status is.

Could be keyring or other mechanisms.

>> It's all relatively easy when you have a separate mount there, so
>> you can store the credentials in the superblock, but we lose on the
>> cache sharing, for example (I don't know how important that is).
> 
> It depends what you mean by "cache sharing". If you're thinking of the
> page cache, then it all just works, provided the underlying inode
> doesn't change.  If you're in the situation where the container

It only "just works" if the superblock is the same, if there's a separate
mount per container with separate superblock, then there's no sharing
at all.
Accounting of said "shared" cache might be interesting too, which
of the containers would you account against? All of them?

>>> Perhaps if you described the actual problem you're seeing rather 
>>> than try to relate it to what I said about superblock namespace 
>>> (which is probably irrelevant), we could figure out what the issue
>>> is.
>> 
>> Right now the deployments are simple and we do not have any major 
>> issues (other than certain caching overzealousness that throws cgroup 
>> memory accounting off), but learning what other problems are there in 
>> this space and what we should be looking for.
> 
> You might need to canvas the other users to see if there is anything
> viable to discuss.

This is what I am trying to do with this email in part, I guess.
