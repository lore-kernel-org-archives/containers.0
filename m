From: Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH v2] xattr: Enable security.capability in user namespaces
Date: Wed, 12 Jul 2017 20:44:28 -0400
Message-ID: <74664cc8-bc3e-75d6-5892-f8934404349f@linux.vnet.ibm.com>
References: <1499785511-17192-1-git-send-email-stefanb@linux.vnet.ibm.com>
	<1499785511-17192-2-git-send-email-stefanb@linux.vnet.ibm.com>
	<87mv89iy7q.fsf@xmission.com> <20170712170346.GA17974@mail.hallyn.com>
	<877ezdgsey.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <877ezdgsey.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: lkp-JC7UmRfGjtg@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org, zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On 07/12/2017 07:13 PM, Eric W. Biederman wrote:
> "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:
>
>> Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
>>> Stefan Berger <"Stefan Bergerstefanb"@linux.vnet.ibm.com> writes:
>>>> Signed-off-by: Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
>>>> Signed-off-by: Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
>>>> Reviewed-by: Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
>>> It doesn't look like this is coming through Serge so I don't see how
>>> the Signed-off-by tag is legtimate.
>> This is mostly explained by the fact that there have been a *lot* of
>> changes, many of them discussed in private emails.
>>
>>> >From the replies to this it doesn't look like Serge has reviewed this
>>> version either.
>>>
>>> I am disappointed that all of my concerns about technical feasibility
>>> remain unaddressed.
>> Can you re-state those, or give a link to them?
> Well I only posted about one substantive comment on the last round
> so it should be easy to find that said.
>
> The big question is how does this intereact with filesystems
> xattr implementations?
>
> There is the potential that we create many more security xattrs this
> way.  How does that scale?  With more names etc.

It doesn't scale. Shared filesystems are a problem if many containers 
use them.

'man listxattr' also mentions this here as a BUG:

" As noted in xattr(7), the VFS imposes a limit of 64 kB on the size of
        the extended attribute name list returned by listxattr(7). If the
        total size of attribute names attached to a file exceeds this limit,
        it is no longer possible to retrieve the list of attribute names."

A simple test on ext4:

#> touch foo
#> for ((i = 0; i < 200; i++)); do setfattr -n user.foo${i} -v hello 
foo; done

user.foo126 was the last one created...

Depending on the size of the data the xattrs are writing, the limit is 
reached sooner. Writing 'hellohello' only goes up to 'user.foo112'. 
Maybe one could try to encode the data more efficiently or as Serge did 
write the uid on the xattr value side, but either way, it won't scale 
due to that VFS limit.

     Stefan

> What happens if we have one xattr per uid for 1000+ uids?

>
> How does this interact with filesystems optimization of xattr names?
> For some filesystems they optmize the xattr names, and don't store the
> entire thing.
>
>> I'd really like to get to a point where unprivileged containers can start
>> using filecaps - at this point if that means having an extra temporary
>> file format based on my earlier patchset while we hash this out, that
>> actually seems worthwhile.  But it would of course be ideal if we could
>> do the name based caps right in the first place.
> This whole new version has set my review back to square one
> unfortunately.
>
> Eric
>
