From: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
Subject: Re: [PATCH 3/4] userns/inotify: Initial implementation of inotify
	per-userns
Date: Thu, 7 Jul 2016 16:40:18 +0300
Message-ID: <577E5BC2.1000208@kyup.com>
References: <1467207425-22072-1-git-send-email-kernel@kyup.com>
	<1467207425-22072-4-git-send-email-kernel@kyup.com>
	<87mvluekun.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87mvluekun.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: jack-AlSwsSmVLrQ@public.gmane.org, avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, operations-/eCPMmvKun9pLGFMi4vTTA@public.gmane.org, gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org



On 07/06/2016 08:29 PM, Eric W. Biederman wrote:
> Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org> writes:
> 
>> This is still very much a WIP and there are certain things which need 
>> to be addressed: 
>>
>> Changes include:
>>
>>  * Added 2 new sysctls:
>>     - inotify_reserved_user_instances and inotify_reserved_user_watches 
>>     these essentially     control the distribution of instances/watches 
>>     down the hierarchy. For example if we have instances/watches limit of 
>>     1024/256 and reserved instances/watches are set to 128/32 then at every 
>>     level of the hierarchy instances/watches are going to be reduced by 128/32, 
>>     so at userns level of 1 (e.g. init_user_ns->level_1_user_ns) each user would
>>     have 896/224 respectively. Currently the defaults are calculated so that at 
>>     least 8 levels of indirection are allowed. Those can be set only by global 
>>     root user.
>>
>>  * When a user inside a NS creates an inotify context for the first time, 
>>  the code locks the whole namespace hierarchy up to the parent of the last 
>>  namespace which has a mapping for a user. And then proceeds to create all 
>>  the intermediary levels. And then unlocks them, this is a bit cumbersome 
>>  IMO but at least ensures that no hard-to-trace races occur.
>>
>> There are also some things which need to be considered:
>>
>>  * One problem currently not resovled is the cleanup of the intermediary
>>  state in namespaces. E.g. if we have a hierarchy of 4 namespaces and an 
>>  inotify instance is created in the bottom-most namespace, and later is 
>>  destroyed this guarantees that only the state in the bottom-most ns is 
>>  freed and not in the intermediary nodes. I guess some sort of hierarchical
>>  mechanism is needed to connect several inotify_state structs. I'm very
>>  much open to discussing how to fix this. Also due to the way locks are 
>>  acquired lockdep prints a splat, but it is a false-positive. 
>>
>>  * Another thing which I think needs serious consideration is the semantic
>>  of the reserved sysctls. What should happen when they are changed - should
>>  those changes propagate to existing counter or shouldn't they? Depending
>>  on the outcome of that decision it's possible to blow the complexity of the
>>  solution through the roof.
> 
> With respect to semantics complexity wise I like how the memory cgroup
> did their hierarchy.  That is changes only take affect at the top most
> level, and nested parts of the hierarchy can theoretically have higher
> limits but you hit the limits at the top of the hierarchy first.
> 
> Definitely a work in progress.
> 
> A couple of comments.
> - See below about permission checks in sysctls.
> - Use kuid_t not uid_t.  Anything else is buggy and hurts my head.
> - The maintenance of the per userns per user information can be handled
>   in kernel/user_namespace.c and simplified such that whenever we create
>   a user namespace it refers to the per userns per user information of
>   the creator of the namespace.  This means at most you need to create
>   a leaf structure at any one point in time, which should greatly
>   simplify things.

I was thinking about that in the beginning but wasn't sure whether this
would be percieved as conflating userns with the inotify intricacies.
However, knowing that you are happy with such an approach I have started
re-implementing this logic such that indeed the userns code is
responsible for managing the nsuser_state struct. And in this struct
there can be arbitrary number of hierarchical counters, each relating to
a different subsystem? What would you say about such an approach? E.g.
in the posted series it was inotify which was freeing the inotify_state
when the last inotify instance was freed in inotify_free_group_priv in
Patch 4/4. Whereas in my second version I intend to move this logic to
the userns code. This will greatly simplify the code.

Also can you explain how is the invariant that a parent ns cannot die
before its children namespace enforced? I didn't see get_user_ns being
called in the ns creation path? In my current code I'd like to rely on
this invariant.


> 
>   The hash table for inotify_state should either be global or be a
>   rhashtable (which is capable of expanding upon use).  Global is
>   arguably easier.  And of course inotify_state should be renamed
>   something like nsuser_state.

For now I have opted for a global hastable, once we have something
working it would be easier to iterate on that.

> 
> 
> I will come back to this but I think that is enough feedback to absorb
> for one round.

Many thanks for the useful feedback.

> 
> Eric
[SNIP]
