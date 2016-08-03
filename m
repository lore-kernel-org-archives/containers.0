From: Nikolay Borisov <n.borisov.lkml-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCHv3] locks: Filter /proc/locks output on proc pid ns
Date: Thu, 4 Aug 2016 00:26:17 +0300
Message-ID: <a0a58f75-0e40-c14f-d8e3-8f094e9fc62c@gmail.com>
References: <1470148943-21835-1-git-send-email-kernel@kyup.com>
	<1470236078-2389-1-git-send-email-kernel@kyup.com>
	<87k2fxom8a.fsf@x220.int.ebiederm.org>
	<1470243015.13804.7.camel@poochiereds.net>
	<87twf1ftk9.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87twf1ftk9.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>
Cc: bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>, avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, xemul-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org
List-Id: containers.vger.kernel.org



On  4.08.2016 00:09, Eric W. Biederman wrote:
> Dumb question does anyone know the difference between fl_nspid and
> fl_pid off the top of your heads?  I am looking at the code and I am
> confused why we have to both.  I am afraid that there was some
> sloppiness when the pid namespace was implemented and this was the
> result.  I remember that file locks were a rough spot during the
> conversion but I don't recall the details off the top of my head.

I think the fl_nspid is the actual pid namespace where the lock was
created, where as pid can be just a unique value required by NFS. I
gathered that information while reading the changelogs and the mailing
list discussion here:
https://lists.linuxfoundation.org/pipermail/containers/2007-December/009044.html
