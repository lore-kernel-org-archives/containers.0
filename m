From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 0/3] keys: play nicely with user namespaces
Date: Fri, 19 Dec 2008 01:07:58 -0800
Message-ID: <m1r6447csx.fsf@frodo.ebiederm.org>
References: <20081219014555.GA25688@us.ibm.com>
	<20081218174613.GA13968@us.ibm.com> <20081217235536.GA932@us.ibm.com>
	<20081212141707.GB9571@us.ibm.com> <20081211232323.GA8343@us.ibm.com>
	<3507.1229086294@redhat.com> <25987.1229097458@redhat.com>
	<3547.1229607983@redhat.com> <7376.1229648192@redhat.com>
	<7658.1229653824@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <7658.1229653824-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> (David Howells's message of "Fri, 19
	Dec 2008 02:30:24 +0000")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
>
>> Yup - patch coming (probably next week) for that,
>
> Thanks.
>
>> but there's the question, given that user namespaces are hierarchical, of
>> whether, if pidns B is a child of pidns A created by userid 500, a task in
>> pidns A should see keys in userns B (listed as belonging to userid 500).
>
> Does that mean all the UIDs of B should be part of A?  Or is just UID 500
> inherited?  Or is UID 0 in B the same as UID 500 in A?

So far the design is that user namespaces are disjoint with one specific exception.

The user who creates the user namespace is expected to have god like powers over
all users in the created user namespace.

When carefully implemented will allow a user namespace to be created
with normal user permissions and for the user that created user
namespace to manage the resources owned by users in that user
namespace.

Eric
