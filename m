From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC PATCH 1/4] Add a user_namespace as creator/owner of
	uts_namespace
Date: Fri, 10 Dec 2010 17:29:10 -0800
Message-ID: <m1r5dpxfkp.fsf__48912.603283725$1292031112$gmane$org@fess.ebiederm.org>
References: <20101209172027.GA10085@mail.hallyn.com>
	<20101211005044.GA25513@p183.telecom.by>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20101211005044.GA25513-ymPLPWd2ZGbSs3Ovhc6N8g@public.gmane.org> (Alexey Dobriyan's
	message of "Sat, 11 Dec 2010 02:50:44 +0200")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, LSM <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Kees Cook <kees.cook-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
List-Id: containers.vger.kernel.org

Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> On Thu, Dec 09, 2010 at 05:20:27PM +0000, Serge E. Hallyn wrote:
>>  struct uts_namespace {
>>  	struct kref kref;
>>  	struct new_utsname name;
>> +	struct user_namespace *user_ns;
>
> You're going to add these to the rest?

That is the idea.

namespaces and other objects of interest will keep a user_ns
pointer referencing the context in which they were created.

I took a quick look and all of the namespaces seem to have capability
checks that we want to allow if you are in the proper context.

What is particularly interesting is that this makes a root user in
something other than the init_user_ns with all capabilities essentially
a normal user because capable(CAP_XXX) becomes capable(&init_user_ns, CAP_XXX).
And as such will always fail except where we have updated the capability
checks.

Eric
