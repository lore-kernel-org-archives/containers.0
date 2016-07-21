From: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH 0/10] userns: sysctl limits for namespaces
Date: Thu, 21 Jul 2016 11:46:48 -0700
Message-ID: <CAGXu5j+eKqxZiHTs5sFCcsuBqRQzWSRvmkQzPy3pNYqL-wNAjA@mail.gmail.com>
References: <8737n5dscy.fsf@x220.int.ebiederm.org>
	<CAGXu5jKWjHKxtPSGuogjR+XE+SbNWiUp2bOxugpD+hUex9QeZA@mail.gmail.com>
	<871t2n53o5.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <871t2n53o5.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Jul 21, 2016 at 9:58 AM, Eric W. Biederman
<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
> Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org> writes:
>
>> On Tue, Jul 19, 2016 at 6:13 PM, Eric W. Biederman
>> <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>>>
>>> This patchset addresses two use cases:
>>> - Implement a sane upper bound on the number of namespaces.
>>> - Provide a way for sandboxes to limit the attack surface from
>>>   namespaces.
>>>
>>> The maximum sane case I can imagine is if every process is a fat
>>> process, so I set the maximum number of namespaces to the maximum
>>> number of threads.
>>>
>>> I make these limits recursive and per user namespace so that a
>>> usernamespace root can reduce the limits further.  If a user namespace
>>> root raises the limit the limit in the parent namespace will be honored.
>>>
>>> I have cut this implementation to the bare minimum needed to achieve
>>> these objections.
>>>
>>> Assuming nothing problematic shows up in the review I will add these to
>>> my user namespace tree.
>>
>> This looks great; thank you! I think the design is effective. One
>> thought that pops to mind is how does an admin query the current
>> number of active namespaces of a given type? (It's likely this is
>> already exposed somewhere and I just don't know where to look...)
>
> You want to give me your acked by on the patches?

Sure thing, consider the series:

Acked-by: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security
