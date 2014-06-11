From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: User namespace over 9p
Date: Wed, 11 Jun 2014 16:14:18 -0700
Message-ID: <87egyvvy2d.fsf@x220.int.ebiederm.org>
References: <53846804.6080408@elastichosts.com>
	<87fvjvpksl.fsf@x220.int.ebiederm.org>
	<539700EC.5010407@elastichosts.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <539700EC.5010407-1hSFou9RDDldEee+Cai+ZQ@public.gmane.org> (Alin Dobre's message of
	"Tue, 10 Jun 2014 13:58:20 +0100")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alin Dobre <alin.dobre-1hSFou9RDDldEee+Cai+ZQ@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, v9fs-developer-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Eric Van Hensbergen <ericvh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Alin Dobre <alin.dobre-1hSFou9RDDldEee+Cai+ZQ@public.gmane.org> writes:

> On 27/05/14 11:39, Eric W. Biederman wrote:
>> If the permission check is made on the kernel with user namespaces we
>> can reasonablly make it work.
>
> I'm pretty sure this is the case and I appreciate your help on this
> matter.

Point me to the permission check in 9p on the client that is failing and
I can advise you on how to update the permission check safely.

Eric
