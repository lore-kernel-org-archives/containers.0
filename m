From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch 2/2] Remove the ns_cgroup
Date: Wed, 6 Jan 2010 16:38:45 -0800
Message-ID: <6599ad831001061638t2f3c4aafl20ba19ec99ed2ec5@mail.gmail.com>
References: <20091228230454.000895089@mai.lab.toulouse-stg.fr.ibm.com>
	<20091228230623.907397717@mai.lab.toulouse-stg.fr.ibm.com>
	<20091228233611.GA6309@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091228233611.GA6309-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Dec 28, 2009 at 3:36 PM, Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> Quoting Daniel Lezcano (daniel.lezcano-GANU6spQydw@public.gmane.org):
>> The ns_cgroup is an annoying cgroup at the namespace / cgroup frontier.
>
> True. =A0However, it remains - apart from using smack or SELinux - the
> only way to truly lock a container into a cgroup configuration. =A0That's
> unlikely to change until we finally support user namespaces in the VFS.
>
> Do we worry about that?

I think we worry about the fact that we don't have a good way to do
this. I don't think we worry about removing a bad way to do it :-)

Paul
