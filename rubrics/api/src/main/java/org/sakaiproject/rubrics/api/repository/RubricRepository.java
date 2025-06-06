/**********************************************************************************
 *
 * Copyright (c) 2017 The Sakai Foundation
 *
 * Original developers:
 *
 *   Unicon
 *
 * Licensed under the Educational Community License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *       http://www.osedu.org/licenses/ECL-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 **********************************************************************************/

package org.sakaiproject.rubrics.api.repository;

import java.util.List;
import java.util.Optional;

import org.sakaiproject.rubrics.api.model.Rubric;
import org.sakaiproject.springframework.data.SpringCrudRepository;

public interface RubricRepository extends SpringCrudRepository<Rubric, Long> {

    Optional<Rubric> findById(Long id);
    Rubric getById(Long id);
    List<Rubric> findByShared(Boolean shared);
    List<Rubric> findByOwnerId(String ownerId);
    int deleteByOwnerId(String ownerId);
}
