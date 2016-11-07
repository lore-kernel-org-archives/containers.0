From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC PATCH] rlimit: Account nproc per-usernamespace/per-user
Date: Mon, 07 Nov 2016 11:28:01 -0600
Message-ID: <87a8db42u6.fsf@xmission.com>
References: <1477485627-16177-1-git-send-email-kernel@kyup.com>
	<8760o7tfa2.fsf@xmission.com>
	<1b593b0d-3e61-ff26-f023-303dcc2debfc@kyup.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1b593b0d-3e61-ff26-f023-303dcc2debfc-6AxghH7DbtA@public.gmane.org> (Nikolay
	Borisov's message of "Thu, 3 Nov 2016 16:59:32 +0200")
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org> writes:

> On 11/01/2016 05:01 PM, Eric W. Biederman wrote:

>> I think conceptually this can work.
>> 
>> Reading through the code I don't see anything capturing the current
>> processes RLIMIT_NPROC when creating a new user namespace.  Which is
>> critical if the limits are going to be enforced hierarchically.
>
> Right, now the question is whether the limits can in fact be enforced
> hierarchically. Because what's really happening is that the actual limit
> is set per-process (in task->signal->rlim[limit].rlim_cur). However, the
> signal struct is being copied when we fork a new process.
>
> With such a setup nothing prevents the parent process to die and thus
> loosing the hierarchical relationship.  Otherwise a rework would need to
> be done to move the rlimits in the struct user_namespace. Essentially
> this is an open problem and it would require some more design thinking
> to get it right.

The only point I see in using the ucount infrastructure is if we limit a
user namespace to the number of processes the creator of user namespace
was allowed to create.  Thus making it impossible to escape your limit
by creating a user namespace and using multiple users.

Your current patch achieves the opposite.  Making it even easier to
escape your current rlimit which is a regression and unacceptable.

>> 
>> I have a small concern that we toss the per user accounting entirely as
>> that means we loose a little in ensuring one uid does not have too many
>> processes.  But that is comparatively minor.
>> 
>> I am buried with Kernel Summit and Plumbers this week, so I will be slow
>> on review etc.
>> 
>> But overall I think this a viable approach assuming there are no
>> performance issues in structuring things this way.
>
> According to my experiments (see reply I sent to Serge) ucount doesn't
> introduce major performance bottlenecks. If you have ideas for a
> particular usecases worth investigating I'm happy to do it. But plain
> old forking should be sufficient.

Which is nice but you have only measured half of what is interesting.
Until there is hierarchical limit enforcement this is uninteresting.

Eric
