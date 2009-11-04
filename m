From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 2/3] cgroups: subsystem module interface
Date: Wed, 4 Nov 2009 13:18:34 -0800
Message-ID: <6599ad830911041318n3a07ef3dgd18dac00c772eeaf@mail.gmail.com>
References: <20091102212825.GA13692@andrew.cmu.edu>
	<20091102213022.GC13692@andrew.cmu.edu>
	<20091104203024.GA14471@andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091104203024.GA14471-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
Cc: bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Nov 4, 2009 at 12:30 PM, Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org> wrote:
>> + =A0 =A0 init_cgroup_css(css, ss, dummytop);
>> + =A0 =A0 init_css_set.subsys[ss->subsys_id] =3D dummytop->subsys[ss->su=
bsys_id];
>
> There is a problem here; namely, the init_css_set is supposed to be
> immutable after boot. Putting a new subsystem state in it seems like it
> will be impossible to get right, since a hierarchy might be mounted and
> already using the init_css_set. Perhaps it would be better to use
> find_css_set for this?

Hmm, it's not just init_css_set that needs to get a pointer to the new
css, it's all existing css_sets - since every task has to start off in
the root cgroup for the new subsystem. A css_set is just a flattened
cache of the css pointers from all the cgroups that a task is a member
of, so when we add a css pointer to the unmount cgroup, we need to
either update all css_set objects, or else run through every task in
the system and update its cgroups pointer to a new css_set that's
equivalent to its old css_set plus the new css pointer.

Given the races inherent in trying to find and update all tasks in the
system, I think the cleanest way to solve this is:

- copy the css_set_table hash table and clear the original table.
- for each bucket in the hash table:
  - for each css_set in the bucket:
    - add the new root css to the css_set
    - rehash the css_set into the hash table

Unfortunately this issue also makes it a bit harder to support
modular-subsystem unloading.

Paul
