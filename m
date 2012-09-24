From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 05/14] userns: Convert hostfs to use kuid and kgid where
	appropriate
Date: Sun, 23 Sep 2012 19:39:02 -0700
Message-ID: <87obkwxhyx.fsf__25305.1300686368$1348454370$gmane$org@xmission.com>
References: <87k3vote43.fsf@xmission.com>
	<1348187330-6616-1-git-send-email-ebiederm@xmission.com>
	<1348187330-6616-5-git-send-email-ebiederm@xmission.com>
	<505F864C.2000103@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <505F864C.2000103-/L3Ra7n9ekc@public.gmane.org> (Richard Weinberger's message of "Sun,
	23 Sep 2012 23:59:40 +0200")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jeff Dike <jdike-OPE4K8JWMJJBDgjK7y7TUQ@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org> writes:

> Am 21.09.2012 02:28, schrieb Eric W. Biederman:
>> From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>> 
>> Cc: Jeff Dike <jdike-OPE4K8JWMJJBDgjK7y7TUQ@public.gmane.org>
>> Cc: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>
>> Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
>> Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>> ---
>
> Looks sane to me.
>
> Acked-by: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>
>
> BTW: How you do test your user namespace patches?
> Is there a generic way to compare/verify uids within a namespace
> vs. the initial namespace?

I start with a well tested set of primites, and a simple design.

Ultimately the goal is to get the conversion functions make_kuid and
from_kuid inserted into the proper locations.

When user namespaces are enabled kuid_t and uid_t are not assignment
compatible so in most places where something needs to be done I get
a compile error.

If the other value is an internal kernel value I change it's type.
If the other value is a userspace or on disk value I insert a conversion
function.

So as a first approximation I can test just by enabling usernamespace
support and compiling the code.

My second line of defense is to keep my patches simple and easily
reviewable.

I impose upon myself the discipline of letting my patches set for a
while so that I review them with a fresh mind before sending them
out to the list.

I am careful when making my patches to actually read the code and
understand what is going on, so hopefully I catch the tricky cases.

With the user namespace support disabled the code performs the same with
except for the conversion functions so things like my conversion of the
core kernel in 3.5 continue to be tested for correctness in general.

Right now for filesystems I am converting them so they will work when
all of the user space interfaces have values coming to the filesystem in
kuid_t and kgid_t, but the values in the filesystem are stored in
the initial user namespace.  So it is trivial to know that I have
useful the correct conversions.

Since my big question is do I have the conversions in all of the
locations needed, compile errors and the discipline of pushing kuid_t
and kgid_t as deep as possible into the kernel data structures as
possible are my primary means of where conversions need to go.

Beyond that I actually run a kernel with all of my patches applied and I
do some spot testing, and I have had my development tree with everything
patched out for a while so that other people can play with it as well.

I also compile test each patch with allyesconfig and with as much
enabled as I can and still leave the usernamespace support enabled,
ensuring each patch is good and safe on it's own (at least compilewise).

So that is how I test.

As to a generic way to compare/verify uids within a namespace vs the
initial namespace hmm.  I don't know that there is a generic tool.  The
mappings are available in /proc/<pid>/uid_maps, and /proc/<pid>/gid_maps
so it isn't hard to look to see if the expected conversion is happening
by looking from outside the namespace. But there isn't a generic tool
that I know of at this point.

Eric
