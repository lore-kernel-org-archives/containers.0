From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH v2] inotify: Convert to using per-namespace limits
Date: Thu, 27 Oct 2016 10:46:27 -0500
Message-ID: <87y419re0c.fsf__12400.7859886207$1477583359$gmane$org@xmission.com>
References: <20161010164046.GG24081@quack2.suse.cz>
	<1476171382-11911-1-git-send-email-kernel@kyup.com>
	<674564a4-ff05-b4d6-4a98-8cfc2e609325@kyup.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <674564a4-ff05-b4d6-4a98-8cfc2e609325-6AxghH7DbtA@public.gmane.org> (Nikolay
	Borisov's message of "Mon, 24 Oct 2016 09:47:44 +0300")
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jack-AlSwsSmVLrQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org> writes:

> On 10/11/2016 10:36 AM, Nikolay Borisov wrote:
>> This patchset converts inotify to using the newly introduced
>> per-userns sysctl infrastructure.
>> 
>> Currently the inotify instances/watches are being accounted in the
>> user_struct structure. This means that in setups where multiple
>> users in unprivileged containers map to the same underlying
>> real user (i.e. pointing to the same user_struct) the inotify limits
>> are going to be shared as well, allowing one user(or application) to exhaust
>> all others limits.
>> 
>> Fix this by switching the inotify sysctls to using the
>> per-namespace/per-user limits. This will allow the server admin to
>> set sensible global limits, which can further be tuned inside every
>> individual user namespace. Additionally, in order to preserve the
>> sysctl ABI make the existing inotify instances/watches sysctls
>> modify the values of the initial user namespace.
>> 
>> Signed-off-by: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
>> ---
>> 
>> So here is a revised version which retains the existing sysctls,
>> and hooks them to the init_user_ns values. 
>
> Gentle ping, now that rc1 has shipped and Jan's sysctl concern hopefully
> resolved.

I plan to give this a once over and merge this.  I have a very funny
pile of serious bug fixes that jumped on my at the beginning of this
development cycle and a cold so I am getting to this more slowly than I
would like.

Eric
