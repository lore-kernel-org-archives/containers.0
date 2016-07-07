From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 3/4] userns/inotify: Initial implementation of inotify
	per-userns
Date: Thu, 07 Jul 2016 10:27:09 -0500
Message-ID: <87inwh31v6.fsf@x220.int.ebiederm.org>
References: <1467207425-22072-1-git-send-email-kernel@kyup.com>
	<1467207425-22072-4-git-send-email-kernel@kyup.com>
	<87mvluekun.fsf@x220.int.ebiederm.org> <577E5BC2.1000208@kyup.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <577E5BC2.1000208-6AxghH7DbtA@public.gmane.org> (Nikolay Borisov's message of "Thu, 7
	Jul 2016 16:40:18 +0300")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
Cc: jack-AlSwsSmVLrQ@public.gmane.org, avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, operations-/eCPMmvKun9pLGFMi4vTTA@public.gmane.org, gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org> writes:

> On 07/06/2016 08:29 PM, Eric W. Biederman wrote:
[snip]
>> Definitely a work in progress.
>> 
>> A couple of comments.
>> - See below about permission checks in sysctls.
>> - Use kuid_t not uid_t.  Anything else is buggy and hurts my head.
>> - The maintenance of the per userns per user information can be handled
>>   in kernel/user_namespace.c and simplified such that whenever we create
>>   a user namespace it refers to the per userns per user information of
>>   the creator of the namespace.  This means at most you need to create
>>   a leaf structure at any one point in time, which should greatly
>>   simplify things.
>
> I was thinking about that in the beginning but wasn't sure whether this
> would be percieved as conflating userns with the inotify intricacies.
> However, knowing that you are happy with such an approach I have started
> re-implementing this logic such that indeed the userns code is
> responsible for managing the nsuser_state struct. And in this struct
> there can be arbitrary number of hierarchical counters, each relating to
> a different subsystem?

Exactly.

> What would you say about such an approach? E.g.
> in the posted series it was inotify which was freeing the inotify_state
> when the last inotify instance was freed in inotify_free_group_priv in
> Patch 4/4. Whereas in my second version I intend to move this logic to
> the userns code. This will greatly simplify the code.

Yes.

Looking at all of the limits that we have as long as we can provide a
general facility that by default needs no tuning or management I think
the user namespace is as good a place as any to provide such counters.

I am a little torn about the idea of having state that is per userns per
user but that is independent of having such a general facility.  We
definietely need a general facility, and per userns per user is
definitely the obvious solution in this case.

> Also can you explain how is the invariant that a parent ns cannot die
> before its children namespace enforced? I didn't see get_user_ns being
> called in the ns creation path? In my current code I'd like to rely on
> this invariant.

The code is sneaky.  It is commented but still sneaky. The code goes:

new = prepare_creds();
ret = create_user_ns(new);

The get_user_ns of new->user_ns is in prepare_creds()

Which is a long way of saying create_user_ns is called with a reference
to the parent namespace.


>>   The hash table for inotify_state should either be global or be a
>>   rhashtable (which is capable of expanding upon use).  Global is
>>   arguably easier.  And of course inotify_state should be renamed
>>   something like nsuser_state.
>
> For now I have opted for a global hastable, once we have something
> working it would be easier to iterate on that.

Sounds good.
>
>> 
>> 
>> I will come back to this but I think that is enough feedback to absorb
>> for one round.
>
> Many thanks for the useful feedback.

Welcome.

For my part I want counts for user namespaces, and network namespaces
and all of the rest, and this looks like the path we need to take to get
there.  Especially for objects that have a user namespace owner.

Eric
